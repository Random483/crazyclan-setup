# UFW firewall is not enabled for desktop/family devices (LAN only).
# -------------------------------------------------------------------
# 20-desktop-core.sh
# Sets up desktop environment and Nextcloud integration
# -------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"


# Load configs
source "$ROOT_DIR/config/users.conf"
source "$ROOT_DIR/config/cloud.conf"

# Load logging functions
source "$ROOT_DIR/lib/logging.sh"
log_stage "20-desktop-core.sh"

# Install Nextcloud client if not present
if ! command -v nextcloud &>/dev/null; then
	echo "==> Installing Nextcloud desktop client"
	apt install -y nextcloud-desktop || echo "Please install nextcloud-desktop manually if this fails."
fi

# Configure Nextcloud client for each user
log_info "Configure Nextcloud client in each user's home directory"
