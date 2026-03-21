#!/bin/bash

# ===============================================
# PHASE: USER SECURITY BASELINE
# ===============================================

log_phase "USER SECURITY" "Sudo installation + privilege assignment"
sleep 2
# -----------------------------------------
# INSTALL SUDO
# -----------------------------------------
log_info "Ensuring sudo is installed..."

install_pkg sudo

# -----------------------------------------
# USER PRIVILEGE CONFIGURATION
# -----------------------------------------
USER_NAME="$(get_real_user)"

log_info "Ensuring user '$USER_NAME' has sudo privileges..."

ensure_user_in_group "$USER_NAME" "sudo"

# -----------------------------------------
# FINAL MESSAGE
# -----------------------------------------
log_phase_1 \
    "${GREEN}SUDO CONFIGURED SUCCESSFULLY" \
    "${YELLOW}User '${WHITE}${BOLD}${USER_NAME}${RESET}${YELLOW}' added to sudo group" \
    "${RED}⚠ ${CYAN} A system reboot is required" \
    "${CYAN}to apply group membership changes"

sleep 2
log_success "Security baseline applied"