#!/usr/bin/env bash

#    Author    : Nishikant Kanunje
#    Date    : 24/04/2026
#    Purpose    : Perform custom git log on list of repositories

# Define ANSI color variables
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

# Print the start banner with purple color
clear -x
echo -e "${MAGENTA}************************************************************************${RESET}"

# Source array of directories
source repositories.sh

# Initialize a counter for numbering the directories
count=0

# Iterate through the list and run 'git status' for each directory
for dir in "${directories[@]}"; do
    echo -e "${CYAN}cd $dir${RESET}"
    cd "$dir" && git log --max-count=1 --pretty=format:"%Cred%h%C(auto)%d - %C(blue)%s%Creset"
    count=$((count + 1))
done

# Print the total number of repositories
echo -e "\n${GREEN}${count} Repositories${RESET}"

# Print the end banner with purple color
echo -e "${MAGENTA}************************************************************************${RESET}"
