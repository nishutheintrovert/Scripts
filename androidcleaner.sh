#!/usr/bin/env bash

# CD into storage (exit immediately if storage path is inaccessible)
cd /storage/emulated/0 || exit 1
shopt -s nullglob dotglob

# Delete target junk directories and prune them from further traversal
find . \( -ipath "./Android/data" -o -ipath "./Android/obb" -o -ipath "./.trash-storage" \) -prune -o \
    -type d \( -name '.thumbnails' -o -name 'debug_log' -o -name '.temp' -o -name '.tubemate' \) -prune -print -exec rm -rf {} +

# Delete 0-byte files except .nomedia
find . \( -ipath "./Android/data" -o -ipath "./Android/obb" -o -ipath "./.trash-storage" \) -prune -o \
    -type f -empty ! -name '.nomedia' -print -exec rm -f {} +

# Bottom-up removal of empty or .nomedia-only directories
find . \( -ipath "./Android/data" -o -ipath "./Android/obb" -o -ipath "./.trash-storage" \) -prune -o \
    -type d ! -name '.' -print0 | sort -rz | while IFS= read -r -d '' dir; do
    files=("$dir"/*)
    if ((${#files[@]} == 0)) || [[ ${#files[@]} -eq 1 && ${files[0]} == "$dir/.nomedia" && ! -d ${files[0]} ]]; then
        printf '%s\n' "$dir"
        rm -rf "$dir"
    fi
done
