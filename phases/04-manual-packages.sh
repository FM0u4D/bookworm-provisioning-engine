#!/bin/bash


#===============================================================
# LOAD LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/../lib/core.sh"
source "$BASE_DIR/../lib/apt.sh"

# ===============================================
# MANUAL PACKAGES
# ===============================================

log_phase "MANUAL PACKAGES" "Custom package installation"
sleep 2

# -----------------------------------------
# FILE PATH
# -----------------------------------------
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANUAL_FILE="$BASE_DIR/config/manual-packages.txt"

# -----------------------------------------
# CHECK FILE EXISTENCE
# -----------------------------------------
if [[ ! -f "$MANUAL_FILE" ]]; then
    log_info "No manual packages file found (skipped)"
    exit 0
fi

# -----------------------------------------
# PARSE PACKAGE LIST
# -----------------------------------------
mapfile -t PACKAGE_LIST < <(
    grep -vE '^\s*$|^\s*#' "$MANUAL_FILE"
)

if [[ ${#PACKAGE_LIST[@]} -eq 0 ]]; then
    log_info "Manual packages file is empty (skipped)"
    exit 0
fi

log_info "Validating manual packages..."

# -----------------------------------------
# CHECK PACKAGE EXISTENCE BEFORE INSTALLING
# -----------------------------------------
INVALID_PKGS=()
VALID_PKGS=()
warn_flag=false

for pkg in "${PACKAGE_LIST[@]}"; do
    if apt-cache show "$pkg" 2>/dev/null | grep -q "^Package:"; then
        VALID_PKGS+=("$pkg")
    else
        INVALID_PKGS+=("$pkg")
    fi
done

# -----------------------------------------
# DECISION LOGIC
# -----------------------------------------
if [[ ${#INVALID_PKGS[@]} -eq 0 ]]; then
    log_success "All manual packages are valid"

elif [[ ${#VALID_PKGS[@]} -eq 0 ]]; then
    log_fail "All provided packages are invalid: ${INVALID_PKGS[*]}"
    warn_flag=true

else
    log_warn_icon "Invalid packages detected: ${INVALID_PKGS[*]}"
    log_info "Proceeding with valid packages only: ${VALID_PKGS[*]}"
    warn_flag=true
fi

# -----------------------------------------
# INSTALLATION
# -----------------------------------------
if [[ "$warn_flag" == false ]]; then
    log_info "Installing manual packages..."
else
    log_info "Installing valid packages only..."
fi

if [[ ${#VALID_PKGS[@]} -gt 0 ]]; then
    install_pkg "${VALID_PKGS[@]}"
    log_success_icon "Manual packages installed"
else
    log_warn_icon "No valid packages to install"
fi

sleep 3