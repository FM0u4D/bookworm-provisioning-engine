#!/bin/bash


STATE_DIR="/var/lib/provision/state"

#===============================================================
# Ensure state directory exists
#===============================================================
init_state_dir() {
    mkdir -p "$STATE_DIR"
}

#===============================================================
# Get state file path
#===============================================================
get_state_file() {
    local phase="$1"
    printf "%s/%s.done" "$STATE_DIR" "$phase"
}

#===============================================================
# Check if phase is completed
#===============================================================
is_phase_done() {
    local phase="$1"
    local state_file

    state_file="$(get_state_file "$phase")"
    [[ -f "$state_file" ]]
}

#===============================================================
# Mark phase as completed
#===============================================================
mark_phase_done() {
    local phase="$1"
    local state_file
    local tmp_file

    init_state_dir

    state_file="$(get_state_file "$phase")"
    tmp_file="${state_file}.tmp"

    {
        printf "phase=%s\n" "$phase"
        printf "date=%s\n" "$(date '+%Y-%m-%d %H:%M:%S')"
        printf "host=%s\n" "$(hostname)"
    } > "$tmp_file"

    mv "$tmp_file" "$state_file"
}

#===============================================================
# Reset a phase
#===============================================================
reset_phase() {
    local phase="$1"
    rm -f "$(get_state_file "$phase")"
}