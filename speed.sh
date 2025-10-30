#!/bin/bash

if [ -z "$2" ]; then
    echo "Usage: $0 <script1> <script2>"
    exit 1
fi

# Array of directories
directories=(
    "/c/users/nishi/desktop/repo_small"
    "/c/users/nishi/desktop/repo_medium"
    "/c/users/nishi/desktop/repo_large"
)

# Initialize a counter for numbering the directories
count=0

# Iterate through the list and call the function for each directory
for dir in "${directories[@]}"; do
    cd "$dir"
    echo -e "\033[0;96m$(basename "$PWD")===========================\033[0m"
    echo $1
    time /c/users/nishi/desktop/$1 >/dev/null
    echo $2
    time /c/users/nishi/desktop/$2 >/dev/null
    count=$((count + 1))
done

# Print the total number of repositories
echo -e "\n\033[0;92m${count} Repositories\033[0m"
