#!/bin/bash


#===============================================================
# LOAD IMPORTANT LIBRARIES
#===============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load libraries relative to repo root
source "$REPO_ROOT/lib/core.sh"
source "$REPO_ROOT/lib/apt.sh"
source "$REPO_ROOT/lib/runtime.sh"


ensure_containerd_service() {
    log_info "Ensuring containerd service is active..."
    sleep 2

    enable_service containerd
    start_service containerd
}

verify_containerd() {
    log_info "Verifying containerd installation..."
    sleep 2

    # Package check
    check_package "containerd.io"

    # Binary check
    check_command containerd

    # Service check
    is_service_active "containerd"

    # Runtime check (Very important)
    check_runtime "containerd" "ctr version" || return 1

    log_success_icon "containerd is fully operational"
}

setup_containerd_repo() {
    log_info "Setting up containerd repo..."

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

    # Update repos
    run_safe apt-get update
}

check_docker_compose() {
    if docker compose version >/dev/null 2>&1; then
        log_success_icon "docker compose plugin is working."
    else
        log_fail_icon "docker compose plugin is NOT available."
        exit 1
    fi
}