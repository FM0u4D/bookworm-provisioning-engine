#!/bin/bash

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