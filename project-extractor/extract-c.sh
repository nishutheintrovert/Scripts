#!/usr/bin/env bash

# 1. Clone the Codespace monorepo
git clone --no-local /d/Codespace ~/Desktop/codespace-temp
cd ~/Desktop/codespace-temp

# 2. Isolate the app's files inside the C directory
git filter-repo \
    --path C/ValorantLoginHelper.c \
    --path C/Valorant.c \
    --path C/Valorant_Login_Helper.c \
    --force

# 3. Flatten the directory and normalize the filenames
git filter-repo \
    --path-rename C/ValorantLoginHelper.c:valorant-login-helper.c \
    --path-rename C/Valorant.c:valorant-login-helper.c \
    --path-rename C/Valorant_Login_Helper.c:valorant-login-helper.c \
    --force

# 4. Lock in your identity and dates for this era
git filter-repo --commit-callback '
commit.author_name = b"Nishikant Kanunje"
commit.committer_name = b"Nishikant Kanunje"
commit.committer_date = commit.author_date
' --force
