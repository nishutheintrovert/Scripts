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

# Paths
SOURCE_DIR="/c/Minecraft/Hunters_Hell/world/"
ARCHIVE_PATH="/c/Minecraft/Hunters_Hell/world.rar"
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

# Step 1: Create archive
"$WINRAR_PATH" a -r -rr5 -ep1 temp.rar "$SOURCE_DIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}Archiving Failed!${RESET}"
    exit 1
fi

# Step 2: Test archive
"$WINRAR_PATH" t temp.rar
if [ $? -ne 0 ]; then
    echo -e "${RED}Archive test failed. Keeping old backup.${RESET}"
    rm -f temp.rar
    exit 1
fi

# Step 3: Replace old archive
mv -f temp.rar "$ARCHIVE_PATH"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error replacing archive!${RESET}"
    exit 1
fi

# Done
echo -e "${GREEN}BACKUP COMPLETE!${RESET}"
