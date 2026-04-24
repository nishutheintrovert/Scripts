#!/usr/bin/env bash

#    Author    : Nishikant Kanunje
#    Date    : 24/04/2026
#    Purpose    : Safely and quickly setup remote for repositories

# Define ANSI color variables
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

# Get current directory name as repository name
reponame=$(basename "$PWD")

# Check if current directory is a Git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${RED}Not a git repository. Please initialize a Git repository first.${RESET}"
    exit 1
fi

# Check if gh CLI is available
if ! command -v gh >/dev/null 2>&1; then
    echo -e "${RED}gh CLI is not installed. Please install it first.${RESET}"
    exit 1
fi

# Check if repository already exists on GitHub and fetch remote URL
if remote=$(gh repo view "$reponame" --json url --template "{{.url}}" 2>/dev/null); then
    echo -e "${RED}Repository ${MAGENTA}$reponame${RED} already exists on ${BLUE}GitHub${RESET}"
    if [ -z "$remote" ]; then
        echo -e "${RED}Failed to extract remote URL from ${BLUE}GitHub${RESET}"
        exit 1
    fi
else
    # Force the current directory into a Unix/POSIX-style path
    unix_pwd=$(cygpath -u "$PWD")
    repo_desc="cd $unix_pwd"

    # Create GitHub repository and store the remote URL
    echo -e "${GREEN}Creating remote ${MAGENTA}$reponame${GREEN} on ${BLUE}GitHub${RESET}"
    if ! remote=$(gh repo create "$reponame" --private -d "$repo_desc" 2>/dev/null); then
        echo -e "${RED}Failed to create repository on ${BLUE}GitHub${RESET}"
        exit 1
    fi
fi

# Add or update 'origin' remote
if ! git remote | grep -q '^origin$'; then
    echo -e "${GREEN}Adding remote ${RED}origin${RESET}"
    git remote add origin "$remote"
else
    echo -e "${GREEN}Updating remote ${RED}origin${RESET}"
    git remote set-url origin "$remote"
fi

# Push to remote
echo -e "${GREEN}Pushing branch ${CYAN}main${GREEN} on remote ${RED}origin${RESET}"
git push -u origin main >/dev/null 2>&1

# Display the remote
echo -e "${BLUE}$remote${RESET}"
