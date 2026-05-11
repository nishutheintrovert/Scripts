#!/usr/bin/env bash

# 1. Clone the monorepo
git clone --no-local /d/Scripts ~/Desktop/scripts-temp
cd ~/Desktop/scripts-temp

# 2. Isolate the app's files (purges the rest of the monorepo history)
git filter-repo \
    --path Valorant_Login.sh \
    --path MouseMover.exe \
    --path Valorant_Accounts \
    --force

# 3. Permanently remove the credential file
git filter-repo \
    --path Valorant_Accounts \
    --invert-paths \
    --force

# 4. Normalize the bash script name
git filter-repo \
    --path-rename Valorant_Login.sh:valorant-login-helper.sh \
    --force

# 5. Lock in your identity and dates for this era
git filter-repo --commit-callback '
commit.author_name = b"Nishikant Kanunje"
commit.committer_name = b"Nishikant Kanunje"
commit.committer_date = commit.author_date
' --force
