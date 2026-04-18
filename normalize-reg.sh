#!/usr/bin/env bash

# Define ANSI color variables
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

echo -e "${BLUE}Scanning for non-ascii .reg files...${RESET}"

find . ! -path '*/.git/*' -type f -name "*.reg" -print0 |
    xargs -0r file -N --mime-encoding |
    awk -F': ' '{printf "%s:%s\0", $1, $2}' |
    while IFS=: read -r -d '' filename encoding; do

        # Filter for anything that isn't already us-ascii
        if [[ "$encoding" != "us-ascii" ]]; then

            tmp_file="${filename}.tmp"

            # Pass the filenames to PowerShell safely via environment variables
            export FILE_IN="$filename"
            export FILE_OUT="$tmp_file"

            # Call PowerShell to read the file and write it back out using a BOM-less UTF-8 encoding object
            powershell.exe -NoProfile -Command "
            \$utf8NoBom = New-Object System.Text.UTF8Encoding \$false;
            [System.IO.File]::WriteAllText(\$env:FILE_OUT, [System.IO.File]::ReadAllText(\$env:FILE_IN), \$utf8NoBom)
        "
            # Replace the original file if the temporary file was successfully created
            if [[ -f "$tmp_file" ]]; then
                mv "$tmp_file" "$filename"

                # Check the new encoding of the file (-b prevents it from printing the filename)
                new_encoding=$(file -b --mime-encoding "$filename")

                echo -e "${YELLOW}Processed: ${CYAN}$filename ${YELLOW}(${RED}$encoding ${MAGENTA}-> ${GREEN}$new_encoding${YELLOW})${RESET}"
            else
                echo -e "${RED}  -> Error: Failed to convert $filename${RESET}"
            fi
        fi
    done
