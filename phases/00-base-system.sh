#!/bin/bash


#===============================================================
# LOAD LIBRARIES
#===============================================================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$BASE_DIR/../lib"

source "$LIB_DIR/colors.sh"
source "$LIB_DIR/system.sh"


# ===============================================
# Checking the least of the least needed commands
# ===============================================

log_phase "BASE SYSTEM INITIALIZATION" "Preflight checks + APT sources"

# -----------------------------------------------
# PREFLIGHT CHECKS
# -----------------------------------------------
preflight_checks() {
    require_root
    require_command "systemctl"
    require_command "apt"
    require_command "dpkg"
    require_command "getent"

    # OS validation
    if ! grep -q "bookworm" /etc/os-release; then
        log_fail_icon "Unsupported OS (expecting Debian 12)"
    fi

    # Checks network connectivity
    # ping -c1 deb.debian.org >/dev/null 2>&1 || log_fail_icon "No network connectivity"
    # ping may not exist yet (iputils-ping not yet installed)
    if ! getent hosts deb.debian.org >/dev/null 2>&1; then
        # DNS check (Important for APT)
        log_fail_icon "DNS resolution failed (APT will not work)"
    fi
}

log_info_icon "Checking system readiness..."
preflight_checks
log_success_icon "System is ready for provisioning"

# -----------------------------------------------
# CONFIGURE APT SOURCES (IDEMPOTENT)
# -----------------------------------------------

EXPECTED_SOURCES="$(cat <<'EOF'
#deb cdrom:[Debian GNU/Linux 12.13.0 _Bookworm_ - Official amd64 NETINST with firmware 20260110-15:42]/ bookworm contrib main non-free-firmware

deb http://deb.debian.org/debian/ bookworm main non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm main non-free-firmware

deb http://security.debian.org/debian-security bookworm-security main non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main non-free-firmware

# bookworm-updates, to get updates before a point release is made;
# see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports
deb http://deb.debian.org/debian/ bookworm-updates main non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm-updates main non-free-firmware

# This system was installed using small removable media
# (e.g. netinst, live or single CD). The matching "deb cdrom"
# entries were disabled at the end of the installation process.
# For information about how to configure apt package sources,
# see the sources.list(5) manual.
EOF
)"

CURRENT_SOURCES="$(grep -v '^#' /etc/apt/sources.list 2>/dev/null | sed '/^$/d' || true)"

if [[ "$CURRENT_SOURCES" == "$EXPECTED_SOURCES" ]]; then
    log_info "APT sources already configured (skipped)"
else
    log_info "Updating APT sources..."

    tmp_file="/etc/apt/sources.list.tmp"

    printf "%s\n" "$EXPECTED_SOURCES" > "$tmp_file"
    mv "$tmp_file" /etc/apt/sources.list

    log_success_icon "APT sources configured"
fi