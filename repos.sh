#!/bin/bash

# List of directories
directories=(
    "/c/HDD_Backup/AHK"
    "/c/HDD_Backup/Codespace"
    "/c/HDD_Backup/College"
    "/c/HDD_Backup/Config"
    "/c/HDD_Backup/Documents"
    "/c/HDD_Backup/Environment"
    "/c/HDD_Backup/Playground"
    "/c/HDD_Backup/Registry"
    "/c/HDD_Backup/Scripts"
    "/c/HDD_Backup/Text"
)

# Initialize a counter for numbering the directories
count=0

# Iterate through the list and call the function for each directory
for dir in "${directories[@]}"; do
    echo -e "\033[0;96mcd $dir\033[0m"
    cd "$dir" && $1
    count=$((count + 1))
done

# Print the total number of repositories
echo -e "\n\033[0;92m${count} Repositories\033[0m"
