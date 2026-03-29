#!/bin/bash


#===============================================================
# LOAD IMPORTANT LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/../core.sh"
source "$BASE_DIR/../runtime.sh"


ensure_containerd_service() {
    log_info "Ensuring containerd service is active..."

    enable_service containerd
    start_service containerd
}

verify_containerd() {
    log_info "Verifying containerd installation..."

    # Package check
    check_package "containerd.io"

    # Binary check
    check_command containerd

    # Service check
    is_service_active "containerd"

    # Runtime check (Very important)
    if ! ctr version &> /dev/null; then
        log_fail "containerd runtime is not responding"
        return 1
    fi

    log_success_icon "containerd is fully operational"
}