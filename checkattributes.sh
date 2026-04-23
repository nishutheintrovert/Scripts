#!/usr/bin/env bash

#    Author    : Nishikant Kanunje
#    Date    : 24/04/2026
#    Purpose    : Check if all file extensions are in .gitattributes file

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
    echo -e "${YELLOW}No files to check.${RESET}"
    exit 0
fi

# 3. .gitattributes file's location
GITATTR_FILE="$GIT_ROOT/.gitattributes"
echo -e "${YELLOW}Checking extensions against ${GITATTR_FILE}${RESET}"

# 4. Stream the valid array into the processing pipeline
if [[ -f "$GITATTR_FILE" ]]; then
    printf '%s\n' "${valid_files[@]}" |
        while IFS= read -r f; do
            filename=$(basename "$f")
            if [[ "$filename" == *.* ]]; then
                echo "${filename##*.}"
            fi
        done |
        sort -u |
        while IFS= read -r ext; do
            if ! grep -q "^\*.$ext" "$GITATTR_FILE" 2>/dev/null; then
                echo -e "${RED}$ext${RESET}" # Print in red if not found
            fi
        done
else
    echo -e "${YELLOW}No .gitattributes file found at $GITATTR_FILE${RESET}"
fi

echo -e "${GREEN}Done!================================${RESET}"
