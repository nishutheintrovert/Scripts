#!/bin/bash

# cd to the directory where the script resides
cd "$(dirname "$0")" || exit 1

find . -type f ! -path '*/.git/*' -print0 | xargs -0 -r file --mime-encoding | grep -v 'binary' | cut -d: -f1 | tr '\n' '\0' | xargs -0 -r -P 0 code

# If file or xarg starts acting funky just copy this command and run manually
# find . -type f ! -path '*/.git/*' -iname "*.sh" -print0 | xargs -0 -r code
