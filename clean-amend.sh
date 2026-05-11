#!/usr/bin/env bash

# Dependancies:
# 0. clean-amend.sh
# 1. attributes.sh
# 2. format.sh
# 3. checkattributes.sh
# 4. rename-files.sh

set -e # We dont want the script to keep going if something breaks

# Guardrail: Prevent accidental execution
if [[ "$1" != "--i-am-aware" ]]; then
    script_name="${BASH_SOURCE[0]}"
    printf '%b Usage: "%s" --i-am-aware\n' "\033[0;31m[BLOCKED]\033[0m" "$script_name"
    return 1 >/dev/null 2>&1 || exit 1
fi

# Run global scripts
attributes.sh
format.sh "$1"
rename-files.sh "$1"

# Renormalize the index and stage only tracked files
git add --renormalize .
git add -u

# Define author identity
while read -r key value; do
    case "$key" in
        user.name) REAL_NAME="$value" ;;
        user.email) REAL_EMAIL="$value" ;;
    esac
done <<<"$(git config --get-regexp "user\.(name|email)")"

# Capture the original author date
ORIGINAL_DATE="$(git log -1 --format=%aD)"

# Amend the commit while preserving the original dates and author
GIT_COMMITTER_DATE="$ORIGINAL_DATE" git commit --amend --no-edit \
    --date="$ORIGINAL_DATE" \
    --author="$REAL_NAME <$REAL_EMAIL>" \
    --allow-empty

# ORIGINAL_DATE="$(git log -1 --format=%aD)" && GIT_COMMITTER_DATE="$ORIGINAL_DATE" git commit --amend --no-edit --date="$ORIGINAL_DATE"
