#!/bin/bash

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
