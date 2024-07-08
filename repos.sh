#!/bin/bash

# List of directories
directories=(
    "/d/AHK"
    "/d/Codespace"
    "/d/Playground"
    "/d/Registry"
    "/d/Scripts"
    "/d/Text"
    "/d/Config"
)

# Iterate through the list and call the function for each directory
for dir in "${directories[@]}"; do
    echo -e "\033[0;96mcd $dir\033[0m"
    cd "$dir" && $1
done
