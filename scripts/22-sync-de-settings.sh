#!/usr/bin/env bash
# -------------------------------------------------------------------
# 22-sync-de-settings.sh (renamed from 27)
# Syncs desktop environment (DE) settings via Nextcloud for KDE, GNOME, and Cosmic
# -------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"


# Load logging functions
source "$ROOT_DIR/lib/logging.sh"
log_stage "22-sync-de-settings.sh"

source "$ROOT_DIR/config/users.conf"
source "$ROOT_DIR/config/cloud.conf"

KDE_CONFIGS=(".config/kdeglobals" ".config/plasma*" ".kde" ".local/share/konsole" ".local/share/kscreen")
GNOME_CONFIGS=(".config/gnome*" ".config/dconf" ".local/share/gnome*" ".gconf" ".gnome2")
COSMIC_CONFIGS=(".config/cosmic*" ".config/pop-*" ".local/share/cosmic*")

DE_SETTINGS_FOLDER="DE-Settings"

for user in "$PRIMARY_USER" "${FAMILY_USERS[@]}"; do
    USER_HOME=$(getent passwd "$user" | cut -d: -f6)
    CLOUD_HOME="$USER_HOME/$CLOUD_DIR_NAME"
    NC_SETTINGS="$CLOUD_HOME/$DE_SETTINGS_FOLDER"
    mkdir -p "$NC_SETTINGS"
    chown "$user:$user" "$NC_SETTINGS"
    for relpath in "${KDE_CONFIGS[@]}"; do
        for src in $USER_HOME/$relpath; do
            [ -e "$src" ] || continue
            base=$(basename "$src")
            target="$NC_SETTINGS/kde-$base"
            if [ ! -L "$src" ]; then
                mv "$src" "$target" 2>/dev/null || cp -a "$src" "$target"
                rm -rf "$src"
                ln -s "$target" "$src"
                chown -h "$user:$user" "$src"
            fi
        done
    done
    for relpath in "${GNOME_CONFIGS[@]}"; do
        for src in $USER_HOME/$relpath; do
            [ -e "$src" ] || continue
            base=$(basename "$src")
            target="$NC_SETTINGS/gnome-$base"
            if [ ! -L "$src" ]; then
                mv "$src" "$target" 2>/dev/null || cp -a "$src" "$target"
                rm -rf "$src"
                ln -s "$target" "$src"
                chown -h "$user:$user" "$src"
            fi
        done
    done
    for relpath in "${COSMIC_CONFIGS[@]}"; do
        for src in $USER_HOME/$relpath; do
            [ -e "$src" ] || continue
            base=$(basename "$src")
            target="$NC_SETTINGS/cosmic-$base"
            if [ ! -L "$src" ]; then
                mv "$src" "$target" 2>/dev/null || cp -a "$src" "$target"
                rm -rf "$src"
                ln -s "$target" "$src"
                chown -h "$user:$user" "$src"
            fi
        done
    done
done

echo "==> DE settings are now synced via Nextcloud in the '$DE_SETTINGS_FOLDER' folder for each user."
echo "==> Folder names used: $DE_SETTINGS_FOLDER/kde-*, $DE_SETTINGS_FOLDER/gnome-*, $DE_SETTINGS_FOLDER/cosmic-*"
