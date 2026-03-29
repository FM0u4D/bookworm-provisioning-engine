#!/bin/bash

#===============================================================
# LOAD LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/../lib/core.sh"
source "$BASE_DIR/../lib/apt.sh"

install_containerd() {
    log_info "Installing containerd (Debian bookworm)..."

    # Pre-check: ensure OS is bookworm
    . /etc/os-release
    if [[ "$ID" != "debian" || "$VERSION_CODENAME" != "bookworm" ]]; then
        log_fail_icon "This module supports only Debian bookworm"
        return 1
    fi

    # Setup keyring
    if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
        log_info "Adding Docker GPG key..."
        run_safe install -m 0755 -d /etc/apt/keyrings
        run_safe curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        run_safe chmod a+r /etc/apt/keyrings/docker.gpg
    else
        log_info "Docker GPG key already exists (skipped)"
    fi

    # Setup repository (force correct config)
    log_info "Configuring Docker repository for bookworm..."
    cat > /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable
EOF

    # Update repo
    run_safe apt-get update

    # Install containerd
    if ! dpkg -l | grep -q containerd.io; then
        log_info "Installing containerd.io..."
        install_pkg "containerd.io"
    else
        log_info "containerd.io already installed"
    fi

    # Ensure service is running
    log_info "Ensuring containerd service is active..."
    run_safe systemctl enable containerd
    run_safe systemctl start containerd

    # 8️⃣ Verification phase
    verify_containerd
}