#!/bin/bash

RED='\033[0;31m'
RESET='\033[0m'

# Print header for text files
echo -e "${RED}Text Files:\\n-----------${RESET}"

# Find all text files in the current directory and its subdirectories
find . -type f ! -path '*/.git/*' -exec file --mime-type {} + | grep -E 'text/' | cut -d: -f1

# Print header for non-text files
echo -e "${RED}NOT Text Files:\\n-----------${RESET}"

# Find all non-text files in the current directory and its subdirectories
find . -type f ! -path '*/.git/*' -exec file --mime-type {} + | grep -E -v 'text/' | cut -d: -f1
