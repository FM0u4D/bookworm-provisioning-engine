#!/bin/bash


#===============================================================
# LOAD LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/../lib/core.sh"
source "$BASE_DIR/../lib/apt.sh"

# ===============================================
# SYSTEM UPDATE
# ===============================================

log_phase "SYSTEM UPDATE" "APT update + upgrade"

# -----------------------------------------
# UPDATE PACKAGE INDEX
# -----------------------------------------
log_info_icon "Updating package index..."
sleep 1
apt_retry update || log_fail_icon "apt update failed"

# -----------------------------------------
# UPGRADE SYSTEM/..
# -----------------------------------------
log_info_icon "Upgrading installed packages..."
sleep 3
apt_retry upgrade -y \
    -o Dpkg::Options::="--force-confnew" \
    -o Dpkg::Options::="--force-confdef" \
    || log_fail_icon "apt upgrade failed"

log_success_icon "System updated successfully"