#!/bin/bash

source "./core.sh"

check_runtime() {
    local name="$1"
    local cmd="$2"

    if ! eval "$cmd" &>/dev/null; then
        log_fail "$name runtime check failed"
        return 1
    fi

    log_success "$name runtime OK"
}
