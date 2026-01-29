#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load role config
source "$ROOT_DIR/config/roles.conf"

echo "==> Bootstrap starting (role: $ROLE)"

# -------------------------------------------------------------------
# Base system (always)
bash "$ROOT_DIR/scripts/00-base.sh"

# -------------------------------------------------------------------
# Identity layer (always, unless explicitly skipped)
bash "$ROOT_DIR/scripts/10-ipa-client.sh"

# -------------------------------------------------------------------
# Role-specific layers
case "$ROLE" in
  dev)
    bash "$ROOT_DIR/scripts/20-desktop-core.sh"
    bash "$ROOT_DIR/scripts/40-dev-tools.sh"
    ;;
  family-desktop)
    bash "$ROOT_DIR/scripts/20-desktop-core.sh"
    bash "$ROOT_DIR/scripts/30-family-tools.sh"
    ;;
  server)
    # Servers still need IPA, but no desktop
    bash "$ROOT_DIR/scripts/30-server-core.sh"
    ;;
  *)
    echo "ERROR: Unknown ROLE '$ROLE'"
    exit 1
    ;;
esac

echo "==> Bootstrap complete"
