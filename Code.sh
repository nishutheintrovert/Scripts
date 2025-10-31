#!/bin/bash
# These files use similar logic so use this in case
# code /d/scripts/Attributes.sh /d/scripts/CheckAttributes.sh /d/scripts/Format.sh /d/scripts/IsText.sh /d/scripts/Code.sh
if [ -n "$1" ]; then
    ext="${1#.}"
    find . -type f ! -path '*/.git/*' -iname "*.$ext" -print0 | xargs -0r code
else
    echo "Usage: $0 [ext] [.ext] [defaults to all text files in current directory]"
    find . -maxdepth 1 -type f ! -path '*/.git/*' -print0 | xargs -0r file --mime-encoding | grep -v 'binary' | cut -d: -f1 | tr '\n' '\0' | xargs -0r code
fi
