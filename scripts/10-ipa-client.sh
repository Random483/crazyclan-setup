#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# 10-ipa-client.sh
# Joins the machine to FreeIPA and enables centralized identity
# -------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load configs
source "$ROOT_DIR/config/ipa.conf"

echo "==> 10-ipa-client: Starting FreeIPA client setup"

# Must run as root
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# -------------------------------------------------------------------
echo "==> Installing FreeIPA client packages"

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
echo "==> Checking if already joined to IPA"

if ipa-client-install --unattended --domain="$IPA_DOMAIN" \
   --server="$IPA_SERVER" \
   --realm="$IPA_REALM" \
   --hostname="$(hostname -f)" \
   --mkhomedir \
   --force-join \
   --principal="$IPA_ADMIN_USER" ; then
    echo "==> IPA enrollment successful"
else
    echo "ERROR: IPA enrollment failed"
    exit 1
fi

# -------------------------------------------------------------------
echo "==> Ensuring SSSD is enabled and running"

systemctl enable sssd
systemctl restart sssd

# -------------------------------------------------------------------
echo "==> Verifying IPA connectivity"

if ! getent passwd admin >/dev/null; then
    echo "ERROR: IPA users not resolvable"
    exit 1
fi

if ! id "$IPA_ADMIN_USER" >/dev/null 2>&1; then
    echo "WARNING: Admin user lookup failed (may be expected)"
fi

# -------------------------------------------------------------------
echo "==> FreeIPA client setup complete"
echo "You should now be able to log in with IPA users."

