#!/usr/bin/env bash
# -------------------------------------------------------------------
# 21-desktop-extras.sh (renamed from 25)
# Installs KDE, GNOME, and developer fonts, Neofetch, etc.
# -------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"


# Load desktop environment config
source "$ROOT_DIR/config/desktop.conf"

# Load logging functions
source "$ROOT_DIR/lib/logging.sh"
log_stage "21-desktop-extras.sh"

apt update -y

case "$DESKTOP_ENV" in
  kde)
    echo "==> Installing KDE Plasma and SDDM"
    apt install -y kde-plasma-desktop sddm
    if [ -f /etc/X11/default-display-manager ]; then
        echo "/usr/bin/sddm" > /etc/X11/default-display-manager
    fi
    ;;
  gnome)
    echo "==> Installing GNOME and GDM3"
    apt install -y gnome-shell gnome-session gdm3
    if [ -f /etc/X11/default-display-manager ]; then
        echo "/usr/sbin/gdm3" > /etc/X11/default-display-manager
    fi
    ;;
  cosmic)
    echo "==> Cosmic desktop is default on Pop!_OS. No extra install needed."
    ;;
  all)
    echo "==> Installing KDE, GNOME, and keeping Cosmic. Users can choose at login."
    apt install -y kde-plasma-desktop sddm gnome-shell gnome-session gdm3
    if [ -f /etc/X11/default-display-manager ]; then
        echo "/usr/bin/sddm" > /etc/X11/default-display-manager
    fi
    ;;
  *)
    echo "[WARN] Unknown DESKTOP_ENV '$DESKTOP_ENV'. Skipping DE install."
    ;;
esac

# Install Neofetch
apt install -y neofetch
if ! grep -q neofetch /etc/skel/.bashrc; then
    echo -e '\n# Show system info on terminal open\nneofetch' >> /etc/skel/.bashrc
fi
for dir in /home/*; do
    if [ -d "$dir" ] && [ -f "$dir/.bashrc" ] && ! grep -q neofetch "$dir/.bashrc"; then
        echo -e '\n# Show system info on terminal open\nneofetch' >> "$dir/.bashrc"
    fi
    chown $(basename "$dir"):$(basename "$dir") "$dir/.bashrc" || true
done

# Install FiraCode and JetBrains Mono fonts
apt install -y fonts-firacode fonts-jetbrains-mono
KDE_GLOBALS="/etc/xdg/kdeglobals"
if [ ! -f "$KDE_GLOBALS" ]; then
    touch "$KDE_GLOBALS"
fi
if ! grep -q "fixed=" "$KDE_GLOBALS"; then
    echo -e "[General]\nfixed=FiraCode,10,-1,5,50,0,0,0,0,0" >> "$KDE_GLOBALS"
else
    sed -i 's/^fixed=.*/fixed=FiraCode,10,-1,5,50,0,0,0,0,0/' "$KDE_GLOBALS"
fi
for dir in /home/*; do
    KDE_USER_GLOBALS="$dir/.config/kdeglobals"
    if [ -d "$dir" ]; then
        mkdir -p "$dir/.config"
        if [ ! -f "$KDE_USER_GLOBALS" ]; then
            echo -e "[General]\nfixed=FiraCode,10,-1,5,50,0,0,0,0,0" > "$KDE_USER_GLOBALS"
        elif ! grep -q "fixed=" "$KDE_USER_GLOBALS"; then
            echo -e "[General]\nfixed=FiraCode,10,-1,5,50,0,0,0,0,0" >> "$KDE_USER_GLOBALS"
        else
            sed -i 's/^fixed=.*/fixed=FiraCode,10,-1,5,50,0,0,0,0,0/' "$KDE_USER_GLOBALS"
        fi
        chown $(basename "$dir"):$(basename "$dir") "$KDE_USER_GLOBALS" || true
    fi
    if [ -f "$dir/.bashrc" ] && ! grep -q neofetch "$dir/.bashrc"; then
        echo -e '\n# Show system info on terminal open\nneofetch' >> "$dir/.bashrc"
        chown $(basename "$dir"):$(basename "$dir") "$dir/.bashrc" || true
    fi

    fc-cache -f -v || true
# End of for loop; removed stray fi

echo "==> KDE, GNOME, Neofetch, and fonts setup complete. Log out and back in to see changes."
