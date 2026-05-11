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

# Guardrail: Prevent accidental execution
if [[ "$1" != "--i-am-aware" ]]; then
    script_name="${BASH_SOURCE[0]}"
    printf '%b Usage: "%s" --i-am-aware\n' "\033[0;31m[BLOCKED]\033[0m" "$script_name"
    return 1 >/dev/null 2>&1 || exit 1
fi
shift # Drop the flag so $1 is now the first specified file, if any

# Arrays
raw_files=()
files=()
lf_files=()
crlf_files=()
sh_files=()

# --- Argument Mode vs Directory Scan ---
if [[ $# -gt 0 ]]; then
    echo -e "${CYAN}Targeting specified files...${RESET}"
    for f in "$@"; do
        if [[ -f "$f" ]]; then
            raw_files+=("$f")
        else
            echo -e "${YELLOW}Warning: $f is not a valid file.${RESET}"
        fi
    done
else
    # Git variables extraction and Root Navigation
    if output=$(git rev-parse --show-toplevel 2>/dev/null); then
        GIT_ROOT="$output"
        GIT_REPO=1
        cd "$GIT_ROOT" || exit
        echo -e "${YELLOW}Git repository detected. Rooted at $GIT_ROOT...${RESET}" >&2
    else
        GIT_REPO=0
        echo -e "${YELLOW}Not a git repository. Operating in current directory...${RESET}" >&2
    fi

    # Run CheckAttributes.sh first for full directory scans
    echo -e "${YELLOW}Running CheckAttributes.sh...${RESET}"

    if command -v CheckAttributes.sh >/dev/null 2>&1; then
        CheckAttributes.sh
    else
        echo -e "${RED}Warning: CheckAttributes.sh not found in PATH.${RESET}" >&2
        return 1 >/dev/null 2>&1 || exit 1
    fi

    echo -e "${CYAN}Scanning directory for text files...${RESET}"

    # Smart directory scanning using null-byte arrays
    if ((GIT_REPO)); then
        echo -e "${YELLOW}Respecting .gitignore natively...${RESET}" >&2
        mapfile -d '' raw_files < <(git ls-files -z -c -o --exclude-standard -- ":(exclude)rename_logs")
    else
        echo -e "${YELLOW}Using standard find fallback...${RESET}" >&2
        mapfile -d '' raw_files < <(find . -type d \( -name ".git" -o -name "rename_logs" \) -prune -o -type f -print0)
    fi
fi

# Batch identify MIME types to prevent slow process forking
if [[ ${#raw_files[@]} -gt 0 ]]; then
    # Filter text files safely
    mapfile -t text_files < <(printf '%s\0' "${raw_files[@]}" | xargs -0r file --mime-encoding | grep -v 'binary' | cut -d: -f1)

    # Preserve the skipped binary warnings when targeting specific files
    if [[ $# -gt 0 ]]; then
        mapfile -t bin_files < <(printf '%s\0' "${raw_files[@]}" | xargs -0r file --mime-encoding | grep 'binary' | cut -d: -f1)
        for b in "${bin_files[@]}"; do
            echo -e "${RED}Skipped: $b is a binary file.${RESET}"
        done
    fi
fi

# Process confirmed text files natively via Bash regex
for f in "${text_files[@]}"; do
    if [[ -f "$f" ]]; then
        files+=("$f")
        filename="${f##*/}"

        # Identify shell scripts for shfmt
        if [[ "$filename" =~ \.(sh|bash|zsh|ksh|fish|fsh)$ ]]; then
            sh_files+=("$f")
        fi

        # LF routing: dotfiles, extensionless, or shell scripts
        if [[ "$filename" == .* || "$filename" != *.* || "$filename" =~ \.(sh|bash|zsh|ksh|fish|fsh)$ ]]; then
            lf_files+=("$f")
        else
            crlf_files+=("$f")
        fi
    fi
done

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

# --- Format shell scripts ---
if [ ${#sh_files[@]} -gt 0 ]; then
    echo -e "${BLUE}Formatting shell scripts${RESET}"
    printf '%s\0' "${sh_files[@]}" | xargs -0r shfmt -l -w -i=4 -ci -ln=bash
fi

# --- Convert standard text files to CRLF ---
if [ ${#crlf_files[@]} -gt 0 ]; then
    echo -e "${MAGENTA}Converting standard text files to CRLF line endings${RESET}"
    printf '%s\0' "${crlf_files[@]}" | xargs -0r unix2dos >/dev/null 2>&1
fi

# --- Convert dotfiles, extensionless, and shell scripts to LF ---
if [ ${#lf_files[@]} -gt 0 ]; then
    echo -e "${CYAN}Converting dotfiles and shell scripts to LF line endings${RESET}"
    printf '%s\0' "${lf_files[@]}" | xargs -0r dos2unix >/dev/null 2>&1
fi

# --- Reset desktop.ini files attributes to be system and hidden
if [[ -z "$1" && -f "desktop.ini" ]]; then
    attrib +s +h desktop.ini
fi
echo -e "${GREEN}Done!================================${RESET}"
