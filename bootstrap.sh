#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load role config
source "$ROOT_DIR/config/roles.conf"

# Always run base
bash "$ROOT_DIR/scripts/00-base.sh"

# Conditionally run next layers
case "$ROLE" in
  dev)
    bash "$ROOT_DIR/scripts/40-dev-tools.sh"
    ;;
  family-desktop)
    bash "$ROOT_DIR/scripts/20-desktop-core.sh"
    ;;
  server)
    bash "$ROOT_DIR/scripts/30-ipa-client.sh"
    ;;
  *)
    echo "Unknown ROLE: $ROLE"
    exit 1
    ;;
esac
