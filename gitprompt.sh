#!/bin/bash

# Define ANSI color variables
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

# Scripts locations
newgitprompt="/C/Program Files/Git/etc/profile.d/git-prompt.sh"
oldgitprompt="/D/Config/old_git-prompt.sh"
configgitprompt="/D/Config/git-prompt.sh"

# Request elevation using powershell if not already admin
if ! net session >/dev/null 2>&1; then
    if ! powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process 'C:\\Program Files\\Git\\git-bash.exe' -ArgumentList '$0' -Verb RunAs"; then
        read -rsn1
        exit 1
    fi
    exit 0
fi

# Check that all files exist, print error for those who don't
for file in "$newgitprompt" "$oldgitprompt" "$configgitprompt"; do
    [ -f "$file" ] || {
        echo -e "${RED}Error: $file not found${RESET}"
        read -rsn1
        exit 1
    }
    # Format files with shfmt, print formatted filenames
    output=$(shfmt -l -w -i=4 -ci -ln=bash "$file")
    [ -n "$output" ] && echo -e "${GREEN}Formatted: $output${RESET}"

done

# Compare newgitprompt against oldgitprompt
if cmp -s "$newgitprompt" "$oldgitprompt"; then
    cp "$configgitprompt" "$newgitprompt"
    echo -e "${GREEN}Files matched. Replaced git-prompt successfully.${RESET}"
    read -rsn1
    exit 0
else
    echo -e "${RED}Warning: $newgitprompt and $oldgitprompt differ. Not replacing.${RESET}"
fi
read -rsn1
