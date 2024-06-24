#!/bin/bash

# Delete empty files before processing, empty files gets added as binary no matter what extension
find . -type f ! -path '*/.git/*' -empty -print -delete

# Main code for Attributes.sh
# Create new .gitattributes file and pass warning
cat >.gitattributes <<EOL
# THIS FILE IS AUTO-GENERATED
# AND MUST BE CHECKED FOR RELIABILITY

EOL

# Mapping of file extensions to specific eol settings
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

# Append detected text files to .gitattributes
echo -e "# Detected text files\\n" >>.gitattributes
find . -type f ! -path '*/.git/*' ! -size 0 | while IFS= read -r file; do
    extension="${file##*.}"
    if [ -n "$extension" ] && [ "$extension" != "$file" ]; then
        # Check if the file is a text file
        if file -b --mime-type "$file" | grep -q "text/"; then
            if ! grep -q "^\*.$extension " .gitattributes; then
                if [ -n "${eol_settings[$extension]}" ]; then
                    echo "*.$extension text eol=${eol_settings[$extension]}" >>.gitattributes
                else
                    echo "*.$extension text" >>.gitattributes
                fi
            fi
        fi
    fi
done

# Append detected binary files to .gitattributes
echo -e "\\n# Detected binary files\\n" >>.gitattributes
find . -type f ! -path '*/.git/*' ! -size 0 | while IFS= read -r file; do
    extension="${file##*.}"
    if [ -n "$extension" ] && [ "$extension" != "$file" ]; then
        # Check if the file is not file
        if ! file -b --mime-type "$file" | grep -q "text/"; then
            if ! grep -q "^\*.$extension " .gitattributes; then
                echo "*.$extension binary" >>.gitattributes
            fi
        fi
    fi
done

# Code from CheckAttributes.sh
# Declare an associative array to track echoed extensions
declare -A echoed_extensions

# Find files and process each one
find . -type f ! -path '*/.git/*' | while IFS= read -r file; do
    extension="${file##*.}" # Extract the file extension
    # Check if the extension is not empty, hasn't been echoed yet, and is not equal to the whole file name
    if [ -n "$extension" ] && [ -z "${echoed_extensions[$extension]}" ] && [ "$extension" != "$file" ]; then
        # Check if the extension is not listed in .gitattributes
        if ! grep -q "^\*.$extension" .gitattributes 2>/dev/null; then
            echo -e "\033[0;31m$extension\033[0m" # Print in red if not found
        fi
        # Mark the extension as echoed
        echoed_extensions[$extension]=1
    fi
done
