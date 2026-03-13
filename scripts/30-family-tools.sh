# -------------------------------------------------------------------
# 30-family-tools.sh
# Installs family desktop applications and configures Java for MultiMC
# -------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load user config
source "$ROOT_DIR/config/users.conf"

echo "==> 30-family-tools: Installing family desktop applications"

# Update package lists
apt update -y

# ----------------------
# Steam
echo "==> Installing Steam"
apt install -y steam || echo "[WARN] Steam install failed, check multiarch and try again manually."

# ----------------------
# Lutris
echo "==> Installing Lutris"
apt install -y lutris

# ----------------------
# MultiMC (AppImage)
echo "==> Installing MultiMC (AppImage)"
MULTIMC_URL="https://files.multimc.org/downloads/mmc-stable-lin64.tar.gz"
MULTIMC_DIR="/opt/multimc"
if [ ! -d "$MULTIMC_DIR" ]; then
	mkdir -p "$MULTIMC_DIR"
	curl -fsSL "$MULTIMC_URL" | tar xz -C "$MULTIMC_DIR" --strip-components=1
	ln -sf "$MULTIMC_DIR/MultiMC" /usr/local/bin/multimc
	echo "[INFO] MultiMC installed to $MULTIMC_DIR"
else
	echo "[INFO] MultiMC already installed."
fi

# ----------------------
# Java version management for MultiMC
echo "==> Installing SDKMAN for Java version management (per user)"
for user in "$PRIMARY_USER" "${FAMILY_USERS[@]}"; do
	USER_HOME=$(getent passwd "$user" | cut -d: -f6)
	if [ -d "$USER_HOME" ]; then
		sudo -u "$user" bash -c 'curl -s "https://get.sdkman.io" | bash' || echo "[WARN] SDKMAN install failed for $user"
	fi
done
echo "[INFO] After login, run 'sdk install java <version>' as needed for MultiMC instances."

# ----------------------
# LibreOffice
echo "==> Installing LibreOffice"
apt install -y libreoffice

# ----------------------
# Firefox
echo "==> Installing Firefox"
apt install -y firefox

# ----------------------
# Chrome (deb package)
echo "==> Installing Google Chrome"
if ! command -v google-chrome &>/dev/null; then
	TMP_DEB="/tmp/google-chrome.deb"
	wget -O "$TMP_DEB" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	apt install -y "$TMP_DEB" || dpkg -i "$TMP_DEB" || echo "[WARN] Chrome install failed."
	rm -f "$TMP_DEB"
else
	echo "[INFO] Chrome already installed."
fi

# ----------------------
# Discord (deb package)
echo "==> Installing Discord"
if ! command -v discord &>/dev/null; then
	TMP_DEB="/tmp/discord.deb"
	wget -O "$TMP_DEB" "https://discord.com/api/download?platform=linux&format=deb"
	apt install -y "$TMP_DEB" || dpkg -i "$TMP_DEB" || echo "[WARN] Discord install failed."
	rm -f "$TMP_DEB"
else
	echo "[INFO] Discord already installed."
fi

# ----------------------

# ----------------------
# GIMP (Photo Editor)
echo "==> Installing GIMP (Photo Editor)"
apt install -y gimp

# VLC
echo "==> Installing VLC"
apt install -y vlc

echo "==> 30-family-tools: Complete"
