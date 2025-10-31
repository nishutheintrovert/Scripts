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

# Delete empty files before processing (file --mime-encoding outputs binary for empty files regardless of extension)
find . -type f ! -path '*/.git/*' -empty -print -delete

# Declare associative array to store EOL settings for text extensions
declare -A eol_settings=(
    ["bash"]="lf"
    ["fish"]="lf"
    ["ksh"]="lf"
    ["sh"]="lf"
    ["zsh"]="lf"
    ["bat"]="crlf"
    ["cmd"]="crlf"
    ["ps1"]="crlf"
    ["vbs"]="crlf"
)

# Initiate new .gitattributes file with text section header
echo -e "${BLUE}Creating .gitattributes${RESET}"
cat >.gitattributes <<EOL
# THIS FILE IS AUTO-GENERATED
# AND MUST BE CHECKED FOR RELIABILITY

# Detected text files

EOL

# Collect all extensions into array (excluding .git)
mapfile -t extensions < <(
    find . -type f ! -path '*/.git/*' -print0 |
        xargs -0r file --mime-encoding |
        while IFS= read -r f; do echo "${f##*.}"; done # Removes filepath from output
    # awk -F'[./:]+' '{print $(NF-1) ":" $(NF)}' # Removes filepath from output
)

# Filter text files and rules to .gitattributes
echo -e "${CYAN}Appending text files${RESET}"
printf '%s\0' "${extensions[@]}" |
    grep -zv 'binary' | cut -zd: -f1 |
    sort -zu | # Removes duplicates and sorts
    # awk -v RS='\0' '!seen[$0]++ { printf "%s\0", $0 }' | # Removes duplicates without sorting
    while IFS= read -r -d '' ext; do
        if [[ -n ${eol_settings[$ext]} ]]; then
            echo "*.$ext text eol=${eol_settings[$ext]}"
        else
            echo "*.$ext text"
        fi
    done >>.gitattributes

# Add binary section header
echo -e "\n# Detected binary files\n" >>.gitattributes

# Filter binary files and rules to .gitattributes
echo -e "${YELLOW}Appending binary files${RESET}"
printf '%s\0' "${extensions[@]}" |
    grep -z 'binary' | cut -zd: -f1 |
    sort -zu | # Removes duplicates and sorts
    # awk -v RS='\0' '!seen[$0]++ { printf "%s\0", $0 }' | # Removes duplicates without sorting
    while IFS= read -r -d '' ext; do
        echo "*.$ext binary"
    done >>.gitattributes

# Normalize line endings to CRLF
unix2dos .gitattributes >/dev/null 2>&1
echo -e "${GREEN}Done!================================${RESET}"
