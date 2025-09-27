#!/bin/bash

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

# Create new .gitattributes file
echo "Creating .gitattributes"
cat >.gitattributes <<EOL
# THIS FILE IS AUTO-GENERATED
# AND MUST BE CHECKED FOR RELIABILITY

# Detected text files

EOL

# Collect unique text file extensions
mapfile -t textextensions < <(
    find . -type f ! -path '*/.git/*' -print0 |
        xargs -0 -r file --mime-encoding |
        grep -v 'binary' |
        cut -d: -f1 |
        tr '\n' '\0' |
        xargs -0 -r -n1 basename |
        while IFS= read -r f; do
            echo "${f##*.}"
        done |
        sort -u
)

# Write text file rules to .gitattributes
for ext in "${textextensions[@]}"; do
    if [[ -n ${eol_settings[$ext]} ]]; then
        echo "*.$ext text eol=${eol_settings[$ext]}" >>.gitattributes
    else
        echo "*.$ext text" >>.gitattributes
    fi
done

# Add binary section header
echo -e "\n# Detected binary files\n" >>.gitattributes

# Collect unique binary file extensions
mapfile -t binaryextensions < <(
    find . -type f ! -path '*/.git/*' -print0 |
        xargs -0 -r file --mime-encoding |
        grep 'binary' |
        cut -d: -f1 |
        tr '\n' '\0' |
        xargs -0 -r -n1 basename |
        while IFS= read -r f; do
            echo "${f##*.}"
        done |
        sort -u
)

# Write binary file rules to .gitattributes
for ext in "${binaryextensions[@]}"; do
    echo "*.$ext binary" >>.gitattributes
done

# Normalize line endings to CRLF
unix2dos .gitattributes >/dev/null 2>&1
