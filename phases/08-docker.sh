#!/bin/bash

set -euo pipefail
#===============================================================
# LOAD LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/../lib/apt.sh"
source "$BASE_DIR/../lib/core.sh"
source "$BASE_DIR/../lib/system.sh"
source "$BASE_DIR/../lib/runtime.sh"
source "$BASE_DIR/../lib/service/containerd.sh"


# Setting up containerd.io APT repo
setup_containerd_repo

# Install "containerd.io"
install_pkg "containerd.io"

# Verification containerd.io package
verify_containerd

# Ensure containerd package is active
ensure_containerd_service

# --- Packages needed for Docker ---
DOCKER_PACKAGES=(
    docker-ce
    docker-ce-cli
    docker-buildx-plugin
    docker-compose-plugin
)

# Install Docker packages
log_info "Installing Docker tooling packages..."
install_pkg "${DOCKER_PACKAGES[@]}"
log_success_icon "Docker tooling installed"

# Enable & start Docker service
log_info "Ensuring Docker service is active..."
enable_service docker
start_service docker

# Verify installation
log_info "Verifying Docker installation..."
check_command docker
#check_command docker-compose
check_docker_compose
check_command docker-buildx

check_runtime "docker" "docker info"

log_success_icon "Docker tooling is fully operational"
