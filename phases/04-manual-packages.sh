#!/bin/bash

# ===============================================
# PHASE: MANUAL PACKAGES
# ===============================================

log_phase "MANUAL PACKAGES" "Custom package installation"

# -----------------------------------------
# FILE PATH
# -----------------------------------------
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANUAL_FILE="$BASE_DIR/config/manual-packages.txt"

# -----------------------------------------
# CHECK FILE EXISTENCE
# -----------------------------------------
if [[ ! -f "$MANUAL_FILE" ]]; then
    log_info "No manual packages file found — skipping"
    exit 0
fi

# -----------------------------------------
# PARSE PACKAGE LIST
# -----------------------------------------
mapfile -t PACKAGE_LIST < <(
    grep -vE '^\s*$|^\s*#' "$MANUAL_FILE"
)

if [[ ${#PACKAGE_LIST[@]} -eq 0 ]]; then
    log_info "Manual packages file is empty — skipping"
    exit 0
fi

log_info "Validating manual packages..."

# -----------------------------------------
# CHECK PACKAGE EXISTENCE BEFORE INSTALLING
# -----------------------------------------
INVALID_PKGS=()

for pkg in "${PACKAGE_LIST[@]}"; do
    if ! apt-cache show "$pkg" >/dev/null 2>&1; then
        INVALID_PKGS+=("$pkg")
    fi
done

if [[ ${#INVALID_PKGS[@]} -ne 0 ]]; then
    log_fail_icon "Invalid packages detected: ${INVALID_PKGS[*]}"
fi

log_success "All manual packages are valid"

# -----------------------------------------
# INSTALLATION
# -----------------------------------------
log_info "Installing manual packages..."

install_pkg "${PACKAGE_LIST[@]}"

log_success_icon "Manual packages installed"
