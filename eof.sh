#!/bin/bash

# Find all files except those in the .git directory, check their MIME type,
# filter only text files, and append a newline if necessary
find . -type f ! -path '*/.git/*' -exec file --mime-type {} + | grep -E 'text/' | cut -d: -f1 | tr '\n' '\0' | xargs -0 -I {} sh -c '
    if [ -n "$(tail -c 1 "{}" | tr -d "\n")" ]; then
        echo >> "{}"
    fi
' sh
