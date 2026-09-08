#!/usr/bin/env bash

#	Author	: Nishikant Kanunje
#	Date	: 09/09/2026
#	Purpose	: Save snapshot of the incomplete browser download

# Use nullglob so the array is empty if no files match
shopt -s nullglob
files=(Unconfirmed*.crdownload)
shopt -u nullglob

# Check the number of matches
if [ ${#files[@]} -eq 0 ]; then
    echo "Error: No matching Unconfirmed*.crdownload file was found in the current directory."
    echo "Press any key to exit..."
    read -rsn1
    exit 1
elif [ ${#files[@]} -gt 1 ]; then
    echo "Warning: Multiple Unconfirmed*.crdownload files found."
    echo "Cannot determine which one to copy. Please leave only one."
    echo "Press any key to exit..."
    read -rsn1
    exit 1
else
    # Exactly one file found, forcefully copy it
    source_file="${files[0]}"
    echo "Found stalled download: '$source_file'"
    echo "Copying to '1.mkv'..."

    # -f forces the overwrite if 1.mkv already exists
    cp -f "$source_file" "1.mkv"

    echo "Done! The file has been secured as 1.mkv."
fi
