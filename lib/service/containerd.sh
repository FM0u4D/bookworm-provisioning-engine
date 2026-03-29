#!/bin/bash


#===============================================================
# LOAD IMPORTANT LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BASE_DIR
source "$BASE_DIR/../core.sh"
source "$BASE_DIR/../runtime.sh"

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