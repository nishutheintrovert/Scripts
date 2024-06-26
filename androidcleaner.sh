#!/bin/bash

# Change to the first directory
cd /storage/D798-66F7/

# Find and delete specific files/directories and empty files/directories
find . \( -empty -o \( -type d -name '.thumbnails' -o -name 'debug_log' -o -name '.nomedia' -o -name '.temp' -o -name '.tubemate' \) \) -print -exec rm -rf {} +

# Change to the second directory
cd /storage/emulated/0

# Find and delete specific files/directories and empty files/directories
find . \( -empty -o \( -type d -name '.thumbnails' -o -name 'debug_log' -o -name '.nomedia' -o -name '.temp' -o -name '.tubemate' \) \) -print -exec rm -rf {} +
