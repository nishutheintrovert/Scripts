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

# Determine the git status option based on the input argument
# if [ "$1" == "--long" ]; then
#     Argument="--long"
# else
#     Argument="-s"
# fi

# Print the start banner with purple color
clear -x
echo -e "${MAGENTA}************************************************************************${RESET}"

# Array of directories
directories=(
    "/d/AHK"
    "/d/Codespace"
    "/d/College"
    "/d/Config"
    "/d/Documents"
    "/d/Environment"
    "/d/Playground"
    "/d/Registry"
    "/d/Scripts"
    "/d/Text"
)

# Initialize a counter for numbering the directories
count=0

# Iterate through the list and run 'git status' for each directory
for dir in "${directories[@]}"; do
    echo -e "${CYAN}cd $dir${RESET}"
    cd "$dir" && git status -s # $Argument
    count=$((count + 1))
done

# Print the total number of repositories
echo -e "\n${GREEN}${count} Repositories${RESET}"

# Print the end banner with purple color
echo -e "${MAGENTA}************************************************************************${RESET}"
