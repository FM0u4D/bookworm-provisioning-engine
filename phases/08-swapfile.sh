#!/bin/bash

#===============================================================
# LOAD LIBRARIES
#===============================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/../lib/core.sh"
source "$BASE_DIR/../lib/system.sh"

# ===============================================
# SWAPFILE
# ===============================================
log_info "Configuring adaptive swapfile..."

SWAPFILE="/swapfile"

# ----------------------------------------
# Detect RAM (in MB)
# ----------------------------------------
RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
log_info "Detected RAM: ${RAM_MB}MB"

# ----------------------------------------
# Determine swap size (policy)
# ----------------------------------------
if [ "$RAM_MB" -le 1024 ]; then
    SWAPSIZE="2G"
elif [ "$RAM_MB" -le 2048 ]; then
    SWAPSIZE="2G"
elif [ "$RAM_MB" -le 4096 ]; then
    SWAPSIZE="2G"
elif [ "$RAM_MB" -le 8192 ]; then
    SWAPSIZE="4G"
else
    SWAPSIZE="2G"
fi

log_info "Calculated swap size: $SWAPSIZE"

# ----------------------------------------
# Memory pressure snapshot (baseline)
# ----------------------------------------
SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')
SWAP_TOTAL=$(free -m | awk '/Swap:/ {print $2}')
log_info "Initial swap usage: ${SWAP_USED}/${SWAP_TOTAL} MB"

# ----------------------------------------
# Check if swap already active
# ----------------------------------------
if swapon --show | grep -q "$SWAPFILE"; then
    log_info "Swapfile already active"
else
    # ----------------------------------------
    # Clean existing (if broken)
    # ----------------------------------------
    if [ -f "$SWAPFILE" ]; then
        log_warn "Existing swapfile found, recreating..."
        swapoff "$SWAPFILE" 2>/dev/null || true
        rm -f "$SWAPFILE"
    fi

    # ----------------------------------------
    # Create swapfile
    # ----------------------------------------
    log_info "Creating swapfile ($SWAPSIZE)..."

    fallocate -l "$SWAPSIZE" "$SWAPFILE" 2>/dev/null || {
        log_warn "fallocate failed, falling back to dd..."

        SIZE_MB=$(echo "$SWAPSIZE" | sed 's/G//')
        SIZE_MB=$((SIZE_MB * 1024))

        dd if=/dev/zero of="$SWAPFILE" bs=1M count="$SIZE_MB" status=progress
    }

    chmod 600 "$SWAPFILE"

    # ----------------------------------------
    # Format & enable
    # ----------------------------------------
    mkswap "$SWAPFILE"
    swapon "$SWAPFILE"

    log_success "Swapfile activated"
fi

# ----------------------------------------
# Persist in fstab (idempotent)
# ----------------------------------------
if ! grep -q "$SWAPFILE" /etc/fstab; then
    echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab
    log_success "Swapfile added to /etc/fstab"
else
    log_info "Swapfile already present in fstab"
fi

# ----------------------------------------
# Memory tuning (GVM-ready)
# ----------------------------------------
log_info "Applying memory performance tuning..."

sysctl -w vm.swappiness=10 >/dev/null
sysctl -w vm.dirty_ratio=15 >/dev/null
sysctl -w vm.dirty_background_ratio=5 >/dev/null

# Persist tuning (idempotent)
grep -q "vm.swappiness" /etc/sysctl.conf || echo "vm.swappiness=10" >> /etc/sysctl.conf
grep -q "vm.dirty_ratio" /etc/sysctl.conf || echo "vm.dirty_ratio=15" >> /etc/sysctl.conf
grep -q "vm.dirty_background_ratio" /etc/sysctl.conf || echo "vm.dirty_background_ratio=5" >> /etc/sysctl.conf

log_success "Memory tuning applied"

# ----------------------------------------
# Final verification snapshot
# ----------------------------------------
log_info "Final memory status:"
free -m

sleep 3
log_success_icon "Adaptive swap configuration completed"