#!/bin/bash


#===============================================================
# LOAD LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/../lib/core.sh"
source "$BASE_DIR/../lib/system.sh"

# ===============================================
# SYSTEM SERVICES
# ===============================================

log_phase "SYSTEM SERVICES" "Enabling core system services"

log_info "Preparing system services..."

# -----------------------------------------
# ENABLE CORE SERVICES
# -----------------------------------------
enable_service "systemd-networkd"
enable_service "systemd-resolved"

if ! service_exists "systemd-resolved"; then
    log_info "This service provides DNS resolution. If you rely on dynamic DNS or systemd-networkd integration, install it manually:"
    echo "${GREEN}       # ${WHITE}${BOLD}apt install systemd-resolved${RESET}"
fi


log_success_icon "System services prepared"