#!/bin/bash


source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

ICON_OK="✔"
ICON_FAIL="✖"
ICON_WARN="⚠"
ICON_INFO="➜"
ICON_WAIT="⏳"


#===============================================================
# Internal printer
#===============================================================
_log() {
    local level="$1"
    local color="$2"
    local message="$3"

    printf "[%b%s%b] %b%s%b\n" "$color" "$level" "$RESET" "$DIM" "$message" "$RESET"
}

_log_icon() {
    local icon="$1"
    local color="$2"
    local message="$3"

    printf "%b%s%b  %b%s%b\n" "$icon" "$color" "$DIM" "$message" "$RESET"
}

#===============================================================
# Phase logging
#===============================================================
strip_ansi() {
    local input="$1"
    local output=""
    local i=0
    local len=${#input}

    while (( i < len )); do
        if [[ "${input:$i:1}" == $'\e' ]]; then
            # Skip ANSI sequence
            while (( i < len )) && [[ "${input:$i:1}" != "m" ]]; do
                ((i++))
            done
        else
            output+="${input:$i:1}"
        fi
        ((i++))
    done

    printf '%s' "$output"
}

apply_phase_color() {
    local msg="$1"

    # Detect ANSI escape sequence
    if [[ "$msg" == *$'\e['* ]]; then
        # Already colored → return as-is
        printf '%s' "$msg"
    else
        # No color → apply default phase color
        printf '%b%s%b' "$COLOR_PHASE" "$msg" "$RESET"
    fi
}

log_phase() {
    local messages=("$@")
    local max_len=0

    #==============================================
    # Find longest visible message (WITHOUT ANSI)
    #==============================================
    for msg in "${messages[@]}"; do
        local clean_msg
        clean_msg=$(strip_ansi "$msg")
        local len=${#clean_msg}
        (( len > max_len )) && max_len=$len
    done

    local padding=2
    local inner_width=$((max_len + padding * 2))

    local line
    line=$(printf '═%.0s' $(seq 1 $inner_width))

    # Top border
    printf "\n%b╔%s╗%b\n" "$MAGENTA" "$line" "$RESET"

    # Content
    for msg in "${messages[@]}"; do
        local clean_msg
        clean_msg=$(strip_ansi "$msg")

        local len=${#clean_msg}
        local space=$((max_len - len))

        printf "%b║%b" "$MAGENTA" "$RESET"

        # Left padding
        printf "%*s" $padding ""

        # Message (colored)
        local colored_msg
        colored_msg=$(apply_phase_color "$msg")

        printf "%b%s%b" "$BOLD" "$colored_msg" "$RESET"

        # Right padding
        printf "%*s" $((space + padding)) ""

        printf "%b║%b\n" "$MAGENTA" "$RESET"
    done

    # Bottom border
    printf "%b╚%s╝%b\n" "$MAGENTA" "$line" "$RESET"
}

#===============================================================
# Standard logs
#===============================================================
log_info()    { _log "INFO"  "$COLOR_INFO"  "$1"; }
log_try()     { _log "RETRY" "$COLOR_TRY"   "$1"; }
log_success() { _log " OK "    "$COLOR_OK"    "$1"; }
log_warn()    { _log "WARN"  "$COLOR_WARN"  "$1"; }

log_fail() {
    _log "FAIL" "$COLOR_FAIL" "$1"
    printf "[%bABORT%b] Provisioning stopped.\n" "$CYAN" "$RESET"
    exit 1
}

log_fail_without_exit() {
    _log "FAIL" "$COLOR_FAIL" "$1"
    printf "[%bABORT%b] Provisioning stopped.\n" "$CYAN" "$RESET"
}

#===============================================================
# Icon logs
#===============================================================
log_info_icon()    { _log_icon "$ICON_INFO" "$COLOR_INFO" "$1"; }
log_success_icon() { _log_icon "$ICON_OK"   "$COLOR_OK"   "$1"; }
log_warn_icon()    { _log_icon "$ICON_WARN" "$COLOR_WARN" "$1"; }
log_wait_icon()    { _log_icon "$ICON_WAIT" "$COLOR_WAIT" "$1"; }

log_fail_icon() {
    _log_icon "$ICON_FAIL" "$COLOR_FAIL" "$1"
    printf "[%bABORT%b] Provisioning stopped.\n" "$CYAN" "$RESET"
    exit 1
}

#===============================================================
# Phase runner (ISOLATED execution)
#===============================================================
run_phase() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        log_fail "Missing phase: $file"
    fi

    #log_phase "Running $(basename "$file")"

    if ! bash "$file"; then
        log_fail "Phase failed: $(basename "$file")"
    fi
}

#===============================================================
# Safe execution wrapper
#===============================================================
run_safe() {
    "$@" || log_fail "Command failed: $*"
}