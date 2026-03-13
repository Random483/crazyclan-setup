SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# Load logging functions
source "$ROOT_DIR/lib/logging.sh"
log_stage "90-cleanup.sh"
# -------------------------------------------------------------------
# 90-cleanup.sh
# Performs basic system cleanup after setup
# -------------------------------------------------------------------
set -euo pipefail

echo "==> 90-cleanup: Starting basic cleanup"

# Remove unused packages and clean apt cache
apt autoremove -y
apt autoclean -y

# Remove leftover .deb files from /tmp
find /tmp -name '*.deb' -delete

echo "==> 90-cleanup: Complete. System is tidy."
