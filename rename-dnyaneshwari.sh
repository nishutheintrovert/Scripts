#!/usr/bin/env bash

# Directory containing the audio files
TARGET_DIR="./Dnyaneshwari"

# Regular expression to extract: Adhyay, Bhag, Start Ovi, End Ovi
# This accounts for variable spaces, underscores, and missing spaces around "ते"
regex="अध्याय[ _]*([0-9]+).*भाग[ _]*([0-9]+).*ओवी[ _]*([0-9]+)[ _]*ते[ _]*([0-9]+)"

# Find all .m4a files and read them safely using null delimiters
find "$TARGET_DIR" -type f -name "*.m4a" -print0 | while IFS= read -r -d $'\0' file; do

    # Extract filename and directory path
    filename=$(basename "$file")
    dirname=$(dirname "$file")

    # Check if the filename matches our regex
    if [[ $filename =~ $regex ]]; then
        adhyay="${BASH_REMATCH[1]}"
        bhag="${BASH_REMATCH[2]}"
        ovi_start="${BASH_REMATCH[3]}"
        ovi_end="${BASH_REMATCH[4]}"

        # Format the new filename with 2-digit and 4-digit zero-padding
        new_filename=$(printf "श्री ज्ञानेश्वरी अध्याय %02d - भाग %02d - ओवी %04d ते %04d.m4a" "$adhyay" "$bhag" "$ovi_start" "$ovi_end")

        old_path="$dirname/$filename"
        new_path="$dirname/$new_filename"

        # Skip if the file is already named perfectly
        if [[ "$old_path" == "$new_path" ]]; then
            continue
        fi

        # DRY RUN: Prints the exact command to the terminal instead of running it.
        # Remove 'echo' from the line below when you are ready to actually rename the files.
        mv "$old_path" "$new_path"

    else
        echo "Warning: Could not extract numbers from '$filename'"
    fi
done
