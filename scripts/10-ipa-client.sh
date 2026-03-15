#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# 10-ipa-client.sh
# Joins the machine to FreeIPA and enables centralized identity
# -------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# open ports
if command -v ufw >/dev/null; then
    systemctl stop ufw || true
    echo "ufw stopped."
else
    echo "ufw not installed, skipping."
fi

# Load configs
source "$ROOT_DIR/config/ipa.conf"

# Load logging functions
source "$ROOT_DIR/lib/logging.sh"
log_stage "10-ipa-client.sh"

# Prompt for IPA admin password if not set
echo "==> 10-ipa-client: Starting FreeIPA client setup"

if [[ -z "${IPA_ADMIN_PASSWORD:-}" ]]; then
    log_info "Enter IPA admin password: "
    read -s IPA_ADMIN_PASSWORD
    echo
fi

log_info "10-ipa-client: Starting FreeIPA client setup"

# Must run as root

if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# -------------------------------------------------------------------
log_info "Installing FreeIPA client packages"

apt install -y \
    freeipa-client \
    sssd \
    sssd-tools \
    oddjob \
    oddjob-mkhomedir \
    libnss-sss \
    libpam-sss \
    adcli \
    packagekit

# -------------------------------------------------------------------
log_info "Checking if already joined to IPA"


if ipa-client-install --unattended --domain="$IPA_DOMAIN" \
   --server="$IPA_SERVER" \
   --realm="$IPA_REALM" \
   --hostname="$(hostname -f)" \
   --mkhomedir \
   --force-join \
   --principal="$IPA_ADMIN_USER" \
   --password="$IPA_ADMIN_PASSWORD" ; then
    log_info "IPA enrollment successful"
else
    log_error "IPA enrollment failed"
    exit 1
fi

# -------------------------------------------------------------------
log_info "Ensuring SSSD is enabled and running"

systemctl enable sssd
systemctl restart sssd


# -------------------------------------------------------------------
log_info "Verifying IPA connectivity"


if ! getent passwd admin >/dev/null; then
    log_error "IPA users not resolvable"
    exit 1
fi

if ! id "$IPA_ADMIN_USER" >/dev/null 2>&1; then
    log_warn "Admin user lookup failed (may be expected)"
fi

# -------------------------------------------------------------------
# Register host in FreeIPA DNS
log_info "Registering host in FreeIPA DNS"
HOST_FQDN="$(hostname -f)"
HOST_SHORT="$(hostname -s)"
HOST_IP="$(hostname -I | awk '{print $1}')"

# Obtain Kerberos ticket for admin user (non-interactive)
echo "$IPA_ADMIN_PASSWORD" | kinit "$IPA_ADMIN_USER"

# Add host if not present
if ! ipa host-show "$HOST_FQDN" >/dev/null 2>&1; then
    ipa host-add "$HOST_FQDN"
else
    log_info "Host $HOST_FQDN already present in FreeIPA."
fi
# Add DNS A record if not present
if ! ipa dnsrecord-show "$IPA_DOMAIN" "$HOST_SHORT" | grep -q "$HOST_IP"; then
    ipa dnsrecord-add "$IPA_DOMAIN" "$HOST_SHORT" --a-rec "$HOST_IP"
else
    log_info "DNS A record for $HOST_SHORT already present."
fi

# -------------------------------------------------------------------
log_info "FreeIPA client setup complete"
log_info "You should now be able to log in with IPA users."
