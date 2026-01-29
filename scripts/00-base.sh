#!/usr/bin/env bash
set -euo pipefail

echo "==> 00-base: Starting base system setup"

# Ensure we're running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------
# System update
# ------------------------------------------------------------------
echo "==> Updating system packages"
apt update
apt -y upgrade

# ------------------------------------------------------------------
# Core utilities (small, boring, essential)
# ------------------------------------------------------------------
echo "==> Installing core utilities"
apt -y install \
  ca-certificates \
  curl \
  wget \
  gnupg \
  lsb-release \
  apt-transport-https \
  software-properties-common \
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
  sudo \
  openssh-client \
  openssh-server

# ------------------------------------------------------------------
# Enable and start SSH (useful even on desktops)
# ------------------------------------------------------------------
echo "==> Enabling SSH service"
systemctl enable ssh
systemctl start ssh

# ------------------------------------------------------------------
# Time & locale sanity
# ------------------------------------------------------------------
echo "==> Setting timezone and locale"
timedatectl set-timezone Europe/London

locale-gen en_GB.UTF-8
update-locale LANG=en_GB.UTF-8

# ------------------------------------------------------------------
# Flatpak & Flathub (Pop!_OS-friendly app delivery)
# ------------------------------------------------------------------
echo "==> Installing Flatpak and enabling Flathub"
apt -y install flatpak

if ! flatpak remote-list | grep -q flathub; then
  flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo
fi

# ------------------------------------------------------------------
# Firewall baseline (non-intrusive)
# ------------------------------------------------------------------
echo "==> Configuring basic firewall"
apt -y install ufw
ufw allow OpenSSH
ufw --force enable

# ------------------------------------------------------------------
# Housekeeping
# ------------------------------------------------------------------
echo "==> Cleaning up"
apt -y autoremove
apt -y autoclean

echo "==> 00-base: Completed successfully"
