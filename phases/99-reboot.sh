#!/bin/bash


#===============================================================
# LOAD LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/../lib/core.sh"
source "$BASE_DIR/../lib/apt.sh"
source "$BASE_DIR/../config/config.sh"

# ===============================================
# PHASE: REBOOT HANDLER
# ===============================================

log_phase "SYSTEM REBOOT" "Finalizing provisioning"

AUTO_REBOOT="${AUTO_REBOOT:-false}"

# -----------------------------------------
# REBOOT LOGIC
# -----------------------------------------
if [[ "$AUTO_REBOOT" == true ]]; then
    log_warn "The system will reboot now in 3s"
    sleep 2
    reboot
else
    log_info "Reboot is recommended to apply all changes"

    read -rp "Do you want to reboot now? (y/n): " choice

    if [[ "$choice" =~ ^[Yy]$ ]]; then
        log_warn "Rebooting system..."
        sleep 2
        reboot
    else
        log_warn_icon "Please reboot manually before continuing setup"
    fi
fi