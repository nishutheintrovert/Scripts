#!/bin/bash

newgitprompt="/C/Program Files/Git/etc/profile.d/git-prompt.sh"
oldgitprompt="/D/Config/old_git-prompt.sh"
configgitprompt="/D/Config/git-prompt.sh"

# Check that all files exist
for file in "$newgitprompt" "$oldgitprompt" "$configgitprompt"; do
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        read -rsn1
    fi
done

# Compare newgitprompt against oldgitprompt
if cmp -s "$newgitprompt" "$oldgitprompt"; then
    cp "$configgitprompt" "$newgitprompt"
    exit 0
else
    echo "Warning: $newgitprompt and $oldgitprompt differ. Not replacing."
fi
read -rsn1
