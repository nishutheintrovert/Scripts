#!/usr/bin/env bash

# 1. Create the final project repository
mkdir ~/Desktop/valorant-login-helper
cd ~/Desktop/valorant-login-helper
git init

# 2. Import the pristine Bash timeline
git remote add bash ~/Desktop/scripts-temp
git fetch bash
git checkout -b main bash/main

# 3. Import the pristine C timeline and stitch them
git remote add c-repo ~/Desktop/codespace-temp
git fetch c-repo
git merge c-repo/main --allow-unrelated-histories -m "Transition to C implementation"

# 4. Flatten the merge into a straight line of history
git rebase --rebase-merges --root

# 5. Rename the first commit and initialize formatting
git rebase -i --root
