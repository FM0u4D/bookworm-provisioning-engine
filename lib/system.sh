#!/bin/bash


# Load dependencies
source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

# ============================================
# USER MANAGEMENT (IDEMPOTENT)
# ============================================
ensure_user_in_group() {
    local user="$1"
    local group="$2"

    if id -nG "$user" | tr ' ' '\n' | grep -qx "$group"; then
        log_info "User $user already in group $group"
    else
        usermod -aG "$group" "$user"
        log_success "Added $user to group $group"
    fi
}

# ============================================
# SERVICE MANAGEMENT (SYSTEMD SAFE)
# ============================================

service_exists() {
    local svc="$1"

    systemctl list-unit-files --type=service --no-legend 2>/dev/null \
        | awk '{print $1}' \
        | grep -qx "${svc}.service"
}

enable_service() {
    local svc="$1"

    # Service not installed → skip cleanly
    if ! service_exists "$svc"; then
        log_warn "Service $svc not found (skipped)"
        return 0
    fi

    # Already enabled
    if systemctl is-enabled "$svc" >/dev/null 2>&1; then
        log_info "Service $svc already enabled"
        return 0
    fi

    # Enable service
    systemctl enable "$svc"
    log_success "Service $svc enabled"
}

start_service() {
    local svc="$1"

    if systemctl is-active --quiet "$svc"; then
        log_info "Service $svc already running"
    else
        systemctl start "$svc" || log_fail "Failed to start $svc"
        log_success "Service $svc started"
    fi
}

is_service_active() {
    if systemctl is-active --quiet "$1"; then
        log_success "$1 service is running perfectly"
    else
        log_fail "$1 service is not running"
    fi
}

# ============================================
# FILE & DIRECTORY MANAGEMENT
# ============================================

ensure_directory() {
    local dir="$1"

    if [[ -d "$dir" ]]; then
        log_info "Directory exists: $dir"
    else
        mkdir -p "$dir"
        log_success "Created directory: $dir"
    fi
}

ensure_file() {
    local file="$1"

    if [[ -f "$file" ]]; then
        log_info "File exists: $file"
    else
        : > "$file"
        log_success "Created file: $file"
    fi
}

# ============================================
# PERMISSIONS MANAGEMENT (IDEMPOTENT)
# ============================================

set_permissions() {
    local path="$1"
    local mode="$2"

    local current
    current=$(stat -c "%a" "$path" 2>/dev/null || echo "")

    if [[ "$current" == "$mode" ]]; then
        log_info "Permissions already set: $path -> $mode"
    else
        chmod "$mode" "$path"
        log_success "Permissions set: $path -> $mode"
    fi
}

set_owner() {
    local path="$1"
    local owner="$2"

    local current
    current=$(stat -c "%U:%G" "$path" 2>/dev/null || echo "")

    if [[ "$current" == "$owner" ]]; then
        log_info "Owner already set: $path -> $owner"
    else
        chown "$owner" "$path"
        log_success "Owner set: $path -> $owner"
    fi
}

# ============================================
# SYSTEM CHECKS (DETERMINISTIC)
# ============================================

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        log_fail "This script must be run as root"
    fi
}

require_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || log_fail "$cmd is required but missing"
}

# ============================================
# ENVIRONMENT UTILITIES
# ============================================

get_real_user() {
    printf "%s\n" "${SUDO_USER:-$(logname 2>/dev/null || echo root)}"
}

# ============================================
# REBOOT HANDLER (CONTROLLED)
# ============================================

handle_reboot() {
    local auto="${AUTO_REBOOT:-false}"

    if [[ "$auto" == true ]]; then
        log_info "Auto reboot enabled"
        reboot
    else
        read -rp "Reboot now? (y/n): " choice
        [[ "$choice" =~ ^[Yy]$ ]] && reboot
    fi
}
