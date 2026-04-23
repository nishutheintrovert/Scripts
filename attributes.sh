#!/usr/bin/env bash

#    Author    : Nishikant Kanunje
#    Date    : 24/04/2026
#    Purpose    : Generate and populate .gitattributes at repositories root

# Define ANSI color variables
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

GIT_ROOT="."
raw_files=()

# 1. Smart directory scanning (Respects .gitignore if available)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Grab the root of the repository
    GIT_ROOT=$(git rev-parse --show-toplevel)
    mapfile -t raw_files < <(git ls-files -c -o --exclude-standard)
else
    mapfile -t raw_files < <(find . -type f ! -path '*/.git/*')
fi

# 2. Delete empty files and build a clean array of valid files
valid_files=()
for f in "${raw_files[@]}"; do
    if [[ -f "$f" ]]; then
        if [[ ! -s "$f" ]]; then
            rm "$f"
        else
            valid_files+=("$f")
        fi
    fi
done

# Exit early if no files to process
if [[ ${#valid_files[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No files to process.${RESET}"
    exit 0
fi

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

# 3. .gitattributes file's location
GITATTR_FILE="$GIT_ROOT/.gitattributes"

# Initiate new .gitattributes file with text section header
echo -e "${BLUE}Creating ${GITATTR_FILE}${RESET}"
cat >"$GITATTR_FILE" <<EOL
# THIS FILE IS AUTO-GENERATED
# AND MUST BE CHECKED FOR RELIABILITY

# Detected text files

EOL

# 3. Collect all extensions and mime-encoding into array by streaming only valid_files
mapfile -t extensions < <(
    printf '%s\0' "${valid_files[@]}" |
        xargs -0r file --mime-encoding |
        while IFS= read -r f; do echo "${f##*.}"; done # Removes filepath from output
)

# Filter text files, add rules
echo -e "${CYAN}Appending text files${RESET}"
printf '%s\0' "${extensions[@]}" |
    grep -zv 'binary' | cut -zd: -f1 |
    sort -zu |
    while IFS= read -r -d '' ext; do
        if [[ -n ${eol_settings[$ext]} ]]; then
            echo "*.$ext text eol=${eol_settings[$ext]}"
        else
            echo "*.$ext text"
        fi
    done >>"$GITATTR_FILE"

# Add binary section header
echo -e "\n# Detected binary files\n" >>"$GITATTR_FILE"

# Filter binary files, add rules
echo -e "${YELLOW}Appending binary files${RESET}"
printf '%s\0' "${extensions[@]}" |
    grep -z 'binary' | cut -zd: -f1 |
    sort -zu |
    while IFS= read -r -d '' ext; do
        echo "*.$ext binary"
    done >>"$GITATTR_FILE"

# Normalize line endings to CRLF
unix2dos "$GITATTR_FILE" >/dev/null 2>&1
echo -e "${GREEN}Done!================================${RESET}"
