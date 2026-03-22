#!/bin/bash

# Prevent reloading
[ -n "${COLORS_LOADED:-}" ] && return
COLORS_LOADED=1

# Detect if terminal supports colors
if [ -t 1 ]; then
    ENABLE_COLOR=true
else
    ENABLE_COLOR=false
fi

# Function to safely assign colors
_color() {
    if [ "$ENABLE_COLOR" = true ]; then
        printf "%b" "$1"
    else
        printf ""
    fi
}

# Reset / styles
RESET=$(_color "\033[0m")
BOLD=$(_color "\033[1m")
DIM=$(_color "\033[2m")

# Base colors
WHITE=$(_color "\033[38;5;255m")
GRAY=$(_color "\033[38;5;245m")

RED=$(_color "\033[38;5;196m")
GREEN=$(_color "\033[38;5;82m")
YELLOW=$(_color "\033[38;5;220m")
ORANGE=$(_color "\033[1;33m")
BLUE=$(_color "\033[38;5;39m")
MAGENTA=$(_color "\033[38;5;131m")
CYAN=$(_color "\033[38;5;51m")

# Semantic aliases (VERY IMPORTANT for maintainability)
COLOR_OK="$GREEN"
COLOR_FAIL="$RED"
COLOR_WARN="$YELLOW"
COLOR_TRY="$CYAN"
COLOR_INFO="$ORANGE"
COLOR_PHASE="$YELLOW"
