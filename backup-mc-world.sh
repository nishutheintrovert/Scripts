#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

# Defining variables
SOURCE_DIR="/c/Minecraft_Server/world/"
DEST_DIR="/c/Minecraft_Server/"
ARCHIVE_NAME="world.rar"
WINRAR_PATH="/c/Program Files/WinRAR/rar.exe"

# Prompt user for confirmation
echo -ne "${CYAN}Do you want to proceed with the backup? (Y/N):${RESET} "
read choice

# Convert input to uppercase to handle lowercase responses
choice=$(echo "$choice" | tr '[:lower:]' '[:upper:]')

if [[ "$choice" != "Y" && "$choice" != "YES" ]]; then
    echo -e "${RED}Backup aborted by user.${RESET}"
    exit 0
fi

# Creating Archive
"$WINRAR_PATH" a -r -ep1 "$ARCHIVE_NAME" "$SOURCE_DIR"
if [ $? -ne 0 ]; then
    echo -e ${RED}Error creating archive!${RESET}
    exit 1
fi

# Testing Archive
"$WINRAR_PATH" t "$ARCHIVE_NAME"
if [ $? -ne 0 ]; then
    echo -e ${RED}Archive test failed!${RESET}
    exit 1
fi

# # Moving Archive
# mv -f "$ARCHIVE_NAME" "$DEST_DIR"
# if [ $? -ne 0 ]; then
#     echo -e ${RED}Error moving archive!${RESET}
#     exit 1
# fi

echo -e ${GREEN}BACKUP COMPLETE!${RESET}
