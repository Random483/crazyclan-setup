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

# Collect all users from PRIMARY_USER and FAMILY_USERS
ALL_USERS=("$PRIMARY_USER" "${FAMILY_USERS[@]}")

for user in "${ALL_USERS[@]}"; do
	if id "$user" &>/dev/null; then
		USER_HOME=$(getent passwd "$user" | cut -d: -f6)
		CLOUD_HOME="$USER_HOME/$CLOUD_DIR_NAME"
		mkdir -p "$CLOUD_HOME"
		chown "$user:$user" "$CLOUD_HOME"
		for dir in "${SYNC_DEFAULT_DIRS[@]}"; do
			TARGET="$CLOUD_HOME/$dir"
			mkdir -p "$TARGET"
			chown "$user:$user" "$TARGET"
			# Optionally, mount or link Nextcloud folders here (WebDAV example):
			# sudo -u "$user" mkdir -p "$TARGET"
			# sudo -u "$user" mount -t davfs "$NEXTCLOUD_URL/remote.php/dav/files/$user/$dir" "$TARGET"
		done
	else
		echo "User $user does not exist (yet). Skipping Nextcloud setup."
	fi
done
