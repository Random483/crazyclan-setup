#!/usr/bin/env bash
# -------------------------------------------------------------------
# logging.sh
# Common logging and stage display functions
# -------------------------------------------------------------------

# Print a colored stage indicator
log_stage() {
    local stage="$1"
    echo -e "\n\033[1;36mCurrent Stage: $stage\033[0m\n"
}

# Example usage for info, warn, error (optional)
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $*"
}
log_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $*"
}
log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $*"
}
