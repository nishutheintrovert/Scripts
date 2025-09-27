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

# Collect all non-binary text files into array (excluding .git)
mapfile -d '' files < <(
    find . -type f ! -path '*/.git/*' -print0 |
        xargs -0 -r file --mime-encoding |
        grep -v 'binary' |
        cut -d: -f1 |
        tr '\n' '\0'
)

# --- Trim trailing spaces and tabs ---
echo -e "${RED}Trimming Whitespaces at end of lines${RESET}"
printf '%s\0' "${files[@]}" | xargs -0 -r -P 4 -n 10 sed -i 's/[ \t]\+$//'

# --- Remove trailing empty lines, ensure final newline ---
echo -e "${GREEN}Trimming empty newlines at end of file${RESET}"
echo -e "${YELLOW}Adding trailing newline at end of file${RESET}"
printf '%s\0' "${files[@]}" | xargs -0 -r -P 4 -n 10 sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' -e '$a\'

# --- Format shell scripts ---
echo -e "${BLUE}Formatting shell scripts${RESET}"
shfmt -l -w -i=4 -ci -ln=bash ./

# --- Convert all files to CRLF ---
echo -e "${MAGENTA}Converting files to CRLF line endings${RESET}"
printf '%s\0' "${files[@]}" | xargs -0 -r -P 4 -n 10 unix2dos >/dev/null 2>&1

# --- Convert Unix specific files to LF ---
echo -e "${CYAN}Converting Unix based files to LF line endings${RESET}"
find . ! -path '*/.git/*' -type f \
    \( -name "*.bash" -o -name "*.fish" -o -name "*.ksh" -o -name "*.sh" -o -name "*.zsh" \) \
    -print0 | xargs -0 -r -P 4 -n 10 dos2unix >/dev/null 2>&1

echo -e "${GREEN}Done!================================${RESET}"
