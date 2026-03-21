#!/bin/bash

# ===============================================
# PHASE: MANUAL PACKAGE VALIDATION
# ===============================================

log_phase "PACKAGE VALIDATION" "Verifying manual packages installation"

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

log_info_icon "Validating installed manual packages..."

# -----------------------------------------
# VALIDATION LOOP (STRICT)
# -----------------------------------------
for pkg in "${PACKAGE_LIST[@]}"; do
    check_package "$pkg"
done

log_success_icon "All manual packages verified successfully"
