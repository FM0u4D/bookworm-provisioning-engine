#!/bin/bash


#===============================================================
# LOAD LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/../lib/core.sh"
source "$BASE_DIR/../lib/system.sh"

# ===============================================
# PHASE: SYSTEM SERVICES
# ===============================================

log_phase "SYSTEM SERVICES" "Enabling core system services"

log_info "Preparing system services..."

# -----------------------------------------
# ENABLE CORE SERVICES
# -----------------------------------------
enable_service "systemd-networkd"
enable_service "systemd-resolved"

log_success_icon "System services prepared"