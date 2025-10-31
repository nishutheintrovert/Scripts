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

echo -e "${YELLOW}Checking extensions against .gitattributes${RESET}"

find . -type f ! -path '*/.git/*' |
    while IFS= read -r f; do echo "${f##*.}"; done |
    sort -u |
    while IFS= read -r ext; do
        if ! grep -q "^\*.$ext" .gitattributes 2>/dev/null; then
            echo -e "${RED}$ext${RESET}" # Print in red if not found
        fi
    done
echo -e "${GREEN}Done!================================${RESET}"
