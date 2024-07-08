#!/bin/bash

# Define ANSI color variables
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

# Determine the git log option based on the input argument
# if [ "$1" == "--decorate" ]; then
#     Argument="--decorate"
# else
#     Argument="--no-decorate"
# fi

# Print the start banner with purple color
clear
echo -e "${MAGENTA}************************************************************************${RESET}"

# Array of directories
directories=(
    "/d/AHK"
    "/d/Codespace"
    "/d/Playground"
    "/d/Registry"
    "/d/Scripts"
    "/d/Text"
    "/d/Config"
)

# Initialize a counter for numbering the directories
count=0

# Iterate through the list and run 'git status' for each directory
for dir in "${directories[@]}"; do
    echo -e "${CYAN}cd $dir${RESET}"
    cd "$dir" && git log # $Argument
    count=$((count + 1))
done

# Print the total number of repositories
echo -e "\n${GREEN}${count} Repositories${RESET}"

# Print the end banner with purple color
echo -e "${MAGENTA}************************************************************************${RESET}"
