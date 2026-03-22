#!/bin/bash

# -----------------------------------------
# INSTALL CORE SYSTEM TOOLS
# -----------------------------------------
# Install required tools
# iproute2 -> provides 'ss'
# net-tools -> provides 'netstat'
# curl -> HTTP testing tool
# -----------------------------------------

#===============================================================
# LOAD LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/../lib/core.sh"
source "$BASE_DIR/../lib/apt.sh"

log_phase "CORE TOOLS INSTALLATION" "Base utilities for system operations"

CORE_PKGS=(
    iproute2
    net-tools
    vim
    git
    iputils-ping
    curl
    wget
    gnupg
    ca-certificates
    lsb-release
)

log_info_icon "Installing core packages..."

install_pkg "${CORE_PKGS[@]}"

# -----------------------------------------
# VALIDATION
# -----------------------------------------
check_command ss
check_command netstat
check_command ping
check_command vim
check_command git
check_command curl
check_command wget
check_command reboot

log_success_icon "Core packages installed"