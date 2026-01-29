#!/usr/bin/env bash
set -e

ROLE="$1"

if[[-z "$ROLE" ]]; then
  echo "Usage: $0 {dev|family|kid}"
  exit 1
fi

for script in scripts/00-base.sh \
                scripts/10-ipa-client.sh \
                scripts/20-cert-trust.sh \
                scripts/30-desktop-core.sh
do
    bash "$script"
done

case "$ROLE" in
  dev)
    bash scripts/40-dev-tools.sh
  ;;
  family)
    bash scripts/50-family-tools.sh
    bash scripts/60-minecraft.sh
    ;;
  kid)
    bash scripts/50-family-tools.sh
    bash scripts/60-minecraft.sh
    ;;
  *)
    echo "Unknown role: $ROLE"
    exit 1
    ;;
esac