#!/usr/bin/env bash

#    Author    : Nishikant Kanunje
#    Date    : 24/04/2026
#    Purpose    : Format all text files in the repository (takes single file as argument)

# Define ANSI color variables
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

files=()

# --- Function to fetch text files ---
get_text_files() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo -e "${YELLOW}Git repository detected. Respecting .gitignore...${RESET}" >&2
        git ls-files -z -c -o --exclude-standard |
            xargs -0r file --mime-encoding | grep -v 'binary' | cut -d: -f1
    else
        echo -e "${YELLOW}Not a git repository. Using standard find fallback...${RESET}" >&2
        find . -type f ! -path '*/.git/*' -print0 |
            xargs -0r file --mime-encoding | grep -v 'binary' | cut -d: -f1
    fi
}

# --- Argument Mode vs Directory Scan ---
if [[ $# -gt 0 ]]; then
    echo -e "${CYAN}Targeting specified files...${RESET}"
    for f in "$@"; do
        if [[ -f "$f" ]]; then
            if ! file --mime-encoding "$f" | grep -q 'binary'; then
                files+=("$f")
            else
                echo -e "${RED}Skipped: $f is a binary file.${RESET}"
            fi
        else
            echo -e "${YELLOW}Warning: $f is not a valid file.${RESET}"
        fi
    done
else
    # Run CheckAttributes.sh first for full directory scans
    echo -e "${YELLOW}Running CheckAttributes.sh...${RESET}"
    if [[ -x "./CheckAttributes.sh" ]]; then
        ./CheckAttributes.sh
    elif [[ -f "./CheckAttributes.sh" ]]; then
        bash ./CheckAttributes.sh
    elif command -v CheckAttributes.sh >/dev/null 2>&1; then
        CheckAttributes.sh
    else
        echo -e "${RED}Warning: CheckAttributes.sh not found locally or in PATH. Skipping.${RESET}" >&2
    fi

    echo -e "${CYAN}Scanning directory for text files...${RESET}"
    mapfile -t files < <(get_text_files)
fi

# Exit gracefully if no valid files were found
if [[ ${#files[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No files to process.${RESET}"
    exit 0
fi

# --- Convert tabs to 4 spaces ---
echo -e "${BLUE}Normalizing tabs to 4 spaces${RESET}"
printf '%s\0' "${files[@]}" | xargs -0r sed -i 's/\t/    /g'

# --- Trim trailing spaces and tabs ---
echo -e "${RED}Trimming Whitespaces at end of lines${RESET}"
printf '%s\0' "${files[@]}" | xargs -0r sed -i 's/[ \t]\+$//'

# --- Remove trailing empty lines, ensure final newline ---
echo -e "${GREEN}Trimming empty newlines at end of file${RESET}"
echo -e "${YELLOW}Adding trailing newline at end of file${RESET}"
printf '%s\0' "${files[@]}" | xargs -0r sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' -e '$a\'

# Filter out only the shell scripts from our safe file list for shfmt
mapfile -t sh_files < <(printf '%s\n' "${files[@]}" | grep -E '\.(sh|bash|zsh|ksh|fish)$')

# --- Format shell scripts ---
if [ ${#sh_files[@]} -gt 0 ]; then
    echo -e "${BLUE}Formatting shell scripts${RESET}"
    printf '%s\0' "${sh_files[@]}" | xargs -0r shfmt -l -w -i=4 -ci -ln=bash
fi

# --- Convert all files to CRLF ---
echo -e "${MAGENTA}Converting files to CRLF line endings${RESET}"
printf '%s\0' "${files[@]}" | xargs -0r unix2dos >/dev/null 2>&1

# --- Convert Unix specific files to LF ---
if [ ${#sh_files[@]} -gt 0 ]; then
    echo -e "${CYAN}Converting Unix based files to LF line endings${RESET}"
    printf '%s\0' "${sh_files[@]}" | xargs -0r dos2unix >/dev/null 2>&1
fi

# --- Reset desktop.ini files attributes to be system and hidden
if [[ -z "$1" && -f "desktop.ini" ]]; then
    attrib +s +h desktop.ini
fi
echo -e "${GREEN}Done!================================${RESET}"
