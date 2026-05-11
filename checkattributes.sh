#!/usr/bin/env bash

#    Author    : Nishikant Kanunje
#    Date    : 07/05/2026
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

# Get git root
GIT_ROOT="."
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    GIT_ROOT=$(git rev-parse --show-toplevel)
fi

# Check for .gitattributes file's existance
GITATTR_FILE="$GIT_ROOT/.gitattributes"

if [[ ! -f "$GITATTR_FILE" ]]; then
    echo -e "${YELLOW}No .gitattributes file found at $GITATTR_FILE${RESET}"
    exit 0
fi

echo -e "${YELLOW}Checking extensions against ${GITATTR_FILE}${RESET}"

# Read patterns from .gitattributes into an associative array
declare -A attributed_patterns
while read -r line || [[ -n "$line" ]]; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^# ]] || [[ -z "${line// /}" ]]; then
        continue
    fi

    # Extract the exact pattern (the first word on the line)
    pattern="${line%% *}"
    attributed_patterns["$pattern"]=1
done <"$GITATTR_FILE"

# Smart directory scanning
raw_files=()
if [[ "$GIT_ROOT" != "." ]]; then
    # Includes tracked (-c) untracked (-o) and ignored (--exclude-standard) files
    mapfile -t raw_files < <(git ls-files -c -o --exclude-standard)
else
    mapfile -t raw_files < <(find . -type d -name ".git" -prune -o -type f)
fi

# Processing & Deduplication

declare -A seen_patterns
for f in "${raw_files[@]}"; do
    # Skip non-files or empty files; delete empty ones
    if [[ ! -s "$f" ]]; then
        [[ -f "$f" ]] && rm "$f"
        continue
    fi

    # Determine exact gitattribute pattern
    filename="${f##*/}"

    if [[ "$filename" == *.* && "$filename" != .* ]]; then
        # Standard files with extensions
        ext="${filename##*.}"
        pattern="*.$ext"
    else
        # Extensionless files and dotfiles
        pattern="$filename"
    fi

    # Build seen pattern array to de-duplicate
    if [[ -z "${seen_patterns[$pattern]}" ]]; then
        seen_patterns["$pattern"]=1

        # Check against patterns in .gitattribute array
        if [[ -z "${attributed_patterns[$pattern]}" ]]; then
            echo -e "${WHITE}$pattern ${RED}Not Found${RESET}" # Print warning if not found
        fi
    fi
done

echo -e "${GREEN}Done!================================${RESET}"
