#!/bin/bash

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
    "/d/skinview3d"
)

# Initialize a counter for numbering the directories
count=0

# Iterate through the list and call the function for each directory
for dir in "${directories[@]}"; do
    echo -e "\033[0;96mcd $dir\033[0m"
    cd "$dir" && "$@"
    count=$((count + 1))
done

# Print the total number of repositories
echo -e "\n\033[0;92m${count} Repositories\033[0m"
