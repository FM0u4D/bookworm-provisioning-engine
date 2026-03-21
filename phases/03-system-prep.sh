#!/bin/bash

# ===============================================
# PHASE: SYSTEM PREPARATION
# ===============================================

log_phase "SYSTEM PREPARATION" "Baseline system configuration"

# -----------------------------------------
# TIMEZONE CONFIGURATION (IDEMPOTENT)
# -----------------------------------------
if [[ "$(readlink -f /etc/localtime)" == "/usr/share/zoneinfo/UTC" ]]; then
    log_info_icon "Timezone already set to UTC"
else
    ln -fs /usr/share/zoneinfo/UTC /etc/localtime
    log_success_icon "Timezone set to UTC"
fi

# -----------------------------------------
# DIRECTORY STRUCTURE
# -----------------------------------------
log_info_icon "Ensuring required directories..."

ensure_directory "/opt"
ensure_directory "/var/log/provision"

log_success_icon "System preparation complete"