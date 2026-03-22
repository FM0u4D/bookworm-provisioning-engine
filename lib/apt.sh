#!/bin/bash

# Ensure non-interactive behavior
export DEBIAN_FRONTEND=noninteractive

APT_UPDATED=false

#===============================================================
# LOAD COLORS LIBRARY
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/core.sh"

#===============================================================
# Retry wrapper for apt-get
#===============================================================
apt_retry() {
    local attempts=3
    local count=1

    while [[ $count -le $attempts ]]; do
        if apt-get "$@"; then
            return 0
        fi

        log_try "apt-get attempt $count failed..."
        sleep 2
        ((count++))
    done

    log_fail "apt-get failed after $attempts attempts"
    return 1
}

#===============================================================
# Update APT only once per run
#===============================================================
apt_update_once() {
    if [[ "$APT_UPDATED" == false ]]; then
        log_info "Updating APT cache..."
        apt_retry update
        APT_UPDATED=true
    fi
}

#===============================================================
# Check if package is installed (boolean)
#===============================================================
is_package_installed() {
    local pkg="$1"
    dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"
}

#===============================================================
# Install packages (idempotent)
#===============================================================
install_pkg() {
    local packages=("$@")
    local to_install=()

    for pkg in "${packages[@]}"; do
        if is_package_installed "$pkg"; then
            log_warn "$pkg already installed (skipped)"
        else
            to_install+=("$pkg")
        fi
    done

    # Nothing to install
    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_info "All packages already installed"
        return 0
    fi

    apt_update_once

    log_info "Installing packages: ${to_install[*]}"

    apt_retry install -y --no-install-recommends \
        -o Dpkg::Options::="--force-confnew" \
        -o Dpkg::Options::="--force-confdef" \
        "${to_install[@]}"

    # Post-install verification
    for pkg in "${to_install[@]}"; do
        if is_package_installed "$pkg"; then
            log_success_icon "${DIM}$pkg${RESET} installed successfully"
        else
            log_fail_icon "${DIM}$pkg${RESET} installation failed"
            exit 1
        fi
    done
}

#===============================================================
# Check command existence in system PATH
#===============================================================
check_command() {
    local cmd="$1"

    if command -v "$cmd" >/dev/null 2>&1; then
        log_success_icon "${DIM}$cmd${RESET} is working."
    else
        log_fail_icon "${DIM}$cmd${RESET} is NOT available."
        exit 1
    fi
}

#===============================================================
# Check package installation status
#===============================================================
check_package() {
    local pkg="$1"

    if is_package_installed "$pkg"; then
        log_success_icon "${DIM}$pkg${RESET} is properly installed."
    else
        log_fail_icon "${DIM}$pkg${RESET} is NOT correctly installed."
        exit 1
    fi
}
#===============================================================