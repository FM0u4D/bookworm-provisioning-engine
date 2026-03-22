#!/bin/bash

set -Eeuo pipefail
IFS=$'\n\t'

# -----------------------------------------
# BASE DIRECTORY
# -----------------------------------------
clear
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BASE_DIR

LIB_DIR="$BASE_DIR/lib/"
PHASE_DIR="$BASE_DIR/phases/"
STATE_DIR="/var/lib/provision/state/"

# -----------------------------------------
# LOAD LIBRARIES
# -----------------------------------------
source "$LIB_DIR/colors.sh"
source "$LIB_DIR/core.sh"
source "$LIB_DIR/apt.sh"
source "$LIB_DIR/state.sh"

# -----------------------------------------
# ENVIRONMENT
# -----------------------------------------
export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

# -----------------------------------------
# INITIALIZE STATE
# -----------------------------------------
init_state_dir

log_phase "STARTING PROVISIONING" "Executing all phases"

# -----------------------------------------
# PHASE ORDER (STRICT)
# -----------------------------------------
PHASES=(
    "00-base-system.sh"
    "01-system-update.sh"
    "02-core-tools.sh"
    "03-system-prep.sh"
    "04-manual-packages.sh"
    "05-validation.sh"
    "06-user-security.sh"
    "07-system-services.sh"
    "99-reboot.sh"
)

# -----------------------------------------
# EXECUTION LOOP (STATE-AWARE)
# -----------------------------------------
for phase in "${PHASES[@]}"; do
    phase_name="${phase%.sh}"
    phase_path="$PHASE_DIR/$phase"

    log_info "Processing phase: $phase_name"

    if is_phase_done "$phase_name"; then
        log_warn "Skipping $phase_name (already completed)"
        continue
    fi

    run_phase "$phase_path"

    mark_phase_done "$phase_name"
done

# -----------------------------------------
# COMPLETION
# -----------------------------------------
log_success_icon "SYSTEM PROVISIONING COMPLETED"
