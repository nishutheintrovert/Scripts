#!/bin/bash

# Find all files (excluding those in .git directory), determine their MIME type,
# filter to include only text files, extract file names, and convert their line endings to DOS format.
# The 'find' command searches for files, 'file --mime-type' determines MIME types, 'grep -E' filters text files,
# 'cut -d: -f1' extracts the file names, 'tr '\n' '\0' converts newline to null character for xargs compatibility,
# and 'xargs -0 -P 4 -n 10 unix2dos' runs unix2dos in parallel (-P 4) on batches of 10 files (-n 10).
find . -type f ! -path '*/.git/*' -exec file --mime-type {} + | grep -E 'text/' | cut -d: -f1 | tr '\n' '\0' | xargs -0 -P 4 -n 10 unix2dos >/dev/null 2>&1

# Find Unix specific script files (excluding those in .git directory),
# and convert their line endings to Unix format.
# The 'find' command searches for files matching specified patterns, 'print0' separates file names by null character,
# and 'xargs -0 -P 4 -n 10 dos2unix' runs dos2unix in parallel (-P 4) on batches of 10 files (-n 10).
find . ! -path '*/.git/*' -type f \( -name "*.bash" -o -name "*.fish" -o -name "*.ksh" -o -name "*.sh" -o -name "*.zsh" \) -print0 | xargs -0 -P 4 -n 10 dos2unix >/dev/null 2>&1
