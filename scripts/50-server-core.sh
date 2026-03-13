# Enable and configure UFW firewall for server role
apt install -y ufw
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
# Ensure UFW allows Nextcloud ports (for server)
if command -v ufw &>/dev/null; then
    log_info "Updating UFW firewall rules for Nextcloud server"
    ufw allow 80/tcp
    ufw allow 443/tcp
fi
#!/usr/bin/env bash
# -------------------------------------------------------------------
# 50-server-core.sh
# Installs core headless/server utilities (no Avahi)
# -------------------------------------------------------------------

set -euo pipefail

# Load logging functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/lib/logging.sh"
log_stage "50-server-core.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Update package lists
apt update -y

# Install monitoring, troubleshooting, and storage tools
apt install -y \
    fail2ban \
    net-tools \
    iproute2 \
    nmap \
    iftop \
    iotop \
    smartmontools \
    logrotate \
    unattended-upgrades \
    exfat-utils \
    ntfs-3g \
    parted \
    lvm2 \
    mailutils \
    nfs-common \
    cifs-utils \
    cron

# Enable and start fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Enable and start unattended-upgrades
systemctl enable unattended-upgrades
systemctl start unattended-upgrades

# Enable and start cron
systemctl enable cron
systemctl start cron

# For Raspberry Pi OS, install raspi-config and rpi-update if available
if grep -qi 'raspbian\|raspberrypi' /etc/os-release 2>/dev/null; then
    apt install -y raspi-config rpi-update || true
fi

echo "==> 50-server-core: Headless/server essentials installed."
