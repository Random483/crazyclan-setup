#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# 00-base.sh
# Sets up the foundational packages and configuration
# --------------------------------------------------
# This script should be safe to re-run and
# only install essentials.
# -------------------------------------------------------------------

# Determine root of our repo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load config
source "$ROOT_DIR/config/locale.conf"
source "$ROOT_DIR/config/paths.conf"
source "$ROOT_DIR/config/roles.conf"

echo "==> 00-base: Initializing base system configuration"

# Must run as root
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Make apt noninteractive
export DEBIAN_FRONTEND=noninteractive

# -------------------------------------------------------------------
echo "==> Updating package lists"
apt update -y
apt upgrade -y

# -------------------------------------------------------------------
echo "==> Installing essential core utilities"
apt install -y \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    unzip \
    zip \
    tar \
    rsync \
    jq \
    vim \
    nano \
    less \
    htop \
    tmux \
    bash-completion \
    openssh-client \
    openssh-server \
    sudo

# -------------------------------------------------------------------
echo "==> Enabling and starting SSH"
systemctl enable ssh
systemctl start ssh

# -------------------------------------------------------------------
echo "==> Installing Flatpak and enabling Flathub"
apt install -y flatpak

if ! flatpak remote-list | grep -q flathub; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# -------------------------------------------------------------------
echo "==> Configuring UFW firewall"
apt install -y ufw
ufw allow OpenSSH

ufw --force enable

# -------------------------------------------------------------------
echo "==> Installing FreeIPA CA certificate (system-wide trust)"
curl -fsSL -o /usr/local/share/ca-certificates/ipa-ca.crt https://ipa.crazyclan.lan/ipa/config/ca.crt
update-ca-certificates

# -------------------------------------------------------------------
echo "==> Configuring timezone and locale"
timedatectl set-timezone "$TIMEZONE"
locale-gen "$LOCALE"
update-locale LANG="$LOCALE"

# -------------------------------------------------------------------
echo "==> Cleanup"
apt autoremove -y
apt autoclean -y

echo "==> 00-base: Complete"
