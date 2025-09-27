#!/bin/bash

# Declare an associative array to track echoed extensions
declare -A echoed_extensions

# Find files and process each one
find . -type f ! -path '*/.git/*' | while IFS= read -r file; do
    basename="${file##*/}"
    if [[ "$basename" == *.* ]]; then
        extension="${basename##*.}"
        # Check if the extension is not empty and hasn't been echoed yet
        if [ -n "$extension" ] && [ -z "${echoed_extensions[$extension]}" ]; then
            # Check if the extension is not listed in .gitattributes
            if ! grep -q "^\*.$extension" .gitattributes 2>/dev/null; then
                echo -e "\033[0;31m$extension\033[0m" # Print in red if not found
            fi
            # Mark the extension as echoed
            echoed_extensions[$extension]=1
        fi
    fi
done
