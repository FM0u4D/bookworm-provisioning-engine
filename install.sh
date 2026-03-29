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

# -----------------------------------------
# PHASE ORDER (STRICT)
# -----------------------------------------
log_phase "STARTING PROVISIONING" "Executing all phases"

PHASES=(
    "00-base-system.sh"
    "01-system-update.sh"
    "02-core-tools.sh"
    "03-system-prep.sh"
    "04-manual-packages.sh"
    "05-validation.sh"
    "06-user-security.sh"
    "07-system-services.sh"
    "08-containerd.sh"
    "09-swapfile.sh"
    "99-reboot.sh"
)

# -----------------------------------------
# EXECUTION LOOP (STATE-AWARE)
# -----------------------------------------
i=5
for phase in "${PHASES[@]}"; do
    ((i++))
    phase_name="${phase%.sh}"
    phase_path="$PHASE_DIR/$phase"

    echo -e ""
    log_info "Processing phase: $phase_name"
    sleep 3
    #Clear everything BELOW header
    echo -ne "\033[${i};1H"
    echo -ne "\033[J"

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
echo -e "\n"
log_success_icon "SYSTEM PROVISIONING COMPLETED"
echo -e "\n"