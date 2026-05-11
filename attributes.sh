#!/usr/bin/env bash

#    Author    : Nishikant Kanunje
#    Date    : 11/05/2026
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

raw_files=()

# 1. Smart directory scanning
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Includes tracked (-c) untracked (-o) and ignored (--exclude-standard) files
    GIT_ROOT=$(git rev-parse --show-toplevel)
    mapfile -t raw_files < <(git ls-files -c -o --exclude-standard)
else
    GIT_ROOT="."
    shopt -s globstar dotglob nullglob # Enable recursive **, hidden files, and empty fallback
    for f in **/*; do
        if [[ -f "$f" && "$f" != .git/* ]]; then
            raw_files+=("$f")
        fi
    done
    shopt -u globstar dotglob nullglob # Turn them back off to be safe
fi

# 2. Process files: delete empty, extract patterns, check mime-type once per pattern
declare -A text_patterns
declare -A binary_patterns
declare -A seen_patterns
valid_file_count=0

for f in "${raw_files[@]}"; do
    if [[ -f "$f" ]]; then
        # Skip and delete empty files
        if [[ ! -s "$f" ]]; then
            rm "$f"
            continue
        fi

        ((valid_file_count++))

        # Determine exact gitattribute pattern using fast parameter expansion
        filename="${f##*/}"

        # Skip git config files (handled in the here-doc)
        if [[ "$filename" == ".gitattributes" || "$filename" == ".gitignore" ]]; then
            continue
        fi

        if [[ "$filename" == *.* && "$filename" != .* ]]; then
            # Standard files with extensions
            ext="${filename##*.}"
            pattern="*.$ext"
        else
            # Extensionless files and dotfiles
            ext="$filename"
            pattern="$filename"
        fi

        # Determine text/binary once per unique pattern
        if [[ -z "${seen_patterns[$pattern]}" ]]; then
            seen_patterns["$pattern"]=1

            # The -b flag omits the filename, returning just 'binary' or 'us-ascii'
            mime=$(file -b --mime-encoding "$f")
            if [[ "$mime" == "binary" ]]; then
                binary_patterns["$pattern"]=1
            else
                # Store the raw 'ext' so we can look it up in eol_settings later
                text_patterns["$pattern"]="$ext"
            fi
        fi
    fi
done

# Exit early if no files to process
if [[ $valid_file_count -eq 0 ]]; then
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
    ["fsh"]="lf"
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

# Core Git files
.gitattributes text eol=lf
.gitignore text eol=lf
EOL

# Append text rules
if [[ ${#text_patterns[@]} -gt 0 ]]; then
    echo -e "${CYAN}Appending text files${RESET}"
    echo -e "\n# Detected text files" >>"$GITATTR_FILE"
    # Extract keys, sort them alphabetically, and process
    mapfile -t sorted_text < <(printf '%s\n' "${!text_patterns[@]}" | sort)
    for pattern in "${sorted_text[@]}"; do
        ext="${text_patterns[$pattern]}"

        # Force eol=lf for dotfiles and extensionless files
        if [[ "$pattern" == .* || "$pattern" != *.* ]]; then
            echo -e "$pattern text eol=lf" >>"$GITATTR_FILE"
        elif [[ -n "${eol_settings[$ext]}" ]]; then
            echo -e "$pattern text eol=${eol_settings[$ext]}" >>"$GITATTR_FILE"
        else
            echo -e "$pattern text" >>"$GITATTR_FILE"
        fi
    done
fi

# Append binary rules
if [[ ${#binary_patterns[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Appending binary files${RESET}"
    echo -e "\n# Detected binary files" >>"$GITATTR_FILE"
    mapfile -t sorted_binary < <(printf '%s\n' "${!binary_patterns[@]}" | sort)
    for pattern in "${sorted_binary[@]}"; do
        echo -e "$pattern binary" >>"$GITATTR_FILE"
    done
fi
echo -e "${GREEN}Done!================================${RESET}"
