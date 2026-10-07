#!/usr/bin/env bash

# CD into storage
cd /storage/emulated/0

# Find and delete specific files/directories and empty files/directories

find . \( -ipath "./Android/data" -o -ipath "./Android/obb" \) -prune -o \( -empty -o \( -type d -name '.thumbnails' -o -name 'debug_log' -o -name '.nomedia' -o -name '.temp' -o -name '.tubemate' \) \) -print -exec rm -rf {} +
