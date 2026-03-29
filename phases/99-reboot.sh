#!/bin/bash


#===============================================================
# LOAD LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/../lib/core.sh"
source "$BASE_DIR/../lib/apt.sh"
source "$BASE_DIR/../config/config.sh"

# ===============================================
# REBOOT HANDLER
# ===============================================

log_phase "SYSTEM REBOOT" "Finalizing provisioning"
sleep 2

AUTO_REBOOT="${AUTO_REBOOT:-false}"

# -----------------------------------------
# REBOOT LOGIC
# -----------------------------------------
if [[ "$AUTO_REBOOT" == true ]]; then
    log_warn "System will reboot automatically in 3 seconds..."
    sleep 3
    reboot
else
    log_info "A system reboot is recommended to apply all changes."

    read -rp "Do you want to reboot now? (Y/n): " choice

    if [[ "$choice" =~ ^[Yy]$ ]]; then
        log_warn "Rebooting system now..."
        sleep 2
        reboot
    else
        log_warn_icon "Please remember to reboot manually later to apply changes."
    fi
fi