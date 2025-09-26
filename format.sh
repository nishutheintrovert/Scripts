#!/bin/bash

# Function to find all non-binary files (excluding .git)
find_text_files() {
    find . -type f ! -path '*/.git/*' -print0 |
        xargs -0 -r file --mime-encoding |
        grep -v 'binary' |
        cut -d: -f1 |
        tr '\n' '\0'
}

# --- Trim trailing spaces and tabs ---
echo "Trimming Whitespaces at end of lines"
find_text_files | xargs -0 -r -P 4 -n 10 sed -i 's/[ \t]\+$//'

# --- Remove trailing empty lines, ensure final newline ---
echo "Trimming empty newlines at end of file"
echo "Adding trailing newline at end of file"
find_text_files | xargs -0 -r -P 4 -n 10 sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' -e '$a\'

# --- Convert all files to CRLF ---
echo "Converting files to CRLF line endings"
find_text_files | xargs -0 -r -P 4 -n 10 unix2dos >/dev/null 2>&1

# --- Convert Unix specific files to LF ---
echo "Converting Unix based files to LF line endings"
find . ! -path '*/.git/*' -type f \( -name "*.bash" -o -name "*.fish" -o -name "*.ksh" -o -name "*.sh" -o -name "*.zsh" \) \
    -print0 | xargs -0 -r -P 4 -n 10 dos2unix >/dev/null 2>&1

echo -e "\033[0;92mDone!\033[0m"
