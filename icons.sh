#!/usr/bin/env bash

ICONEXT_EXE_PATH="/C/Tools/iconsext/iconsext.exe"

TARGET_EXE="$1"

if [ -z "$TARGET_EXE" ]; then
    echo "Error: No target executable provided."
    echo ""
    echo "Usage: $(basename "$0") 'path_to_target_exe_or_dll'"
    echo ""
    read -r -p "Please enter the path to the target executable: " TARGET_EXE

    if [ -z "$TARGET_EXE" ]; then
        read -rsn1 -p "No path entered. Aborting."
        echo ""
        exit 1
    fi
fi

# ---> THE FIX: Remove any literal quotes the user might have pasted <---
TARGET_EXE="${TARGET_EXE//[\"\']/}"

# 1. Convert the input to a Unix-style path so Bash can test if it exists
UNIX_TARGET_EXE=$(cygpath -u "$TARGET_EXE")

# 2. Check if the file is valid
if [ ! -f "$UNIX_TARGET_EXE" ]; then
    echo ""
    echo "Error: File does not exist -> $TARGET_EXE"
    read -rsn1 -p "Press any key to exit..."
    echo ""
    exit 1
fi

OUTPUT_DIR="$USERPROFILE/Desktop"

# 3. Convert both paths to strict Windows format for iconsext.exe
WIN_TARGET=$(cygpath -w "$TARGET_EXE")
WIN_OUTPUT=$(cygpath -w "$OUTPUT_DIR")

echo ""
echo "Extracting icons from: $WIN_TARGET"
echo "Saving to: $WIN_OUTPUT"

# Pass the strictly formatted Windows paths to the executable
"$ICONEXT_EXE_PATH" //save "$WIN_TARGET" "$WIN_OUTPUT" -icons

if [ $? -eq 0 ]; then
    exit 0
else
    read -rsn1 -p "Error: iconsext.exe failed to extract icons."
    echo ""
    exit 1
fi
