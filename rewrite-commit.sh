#!/usr/bin/env bash

# Skip accidental runs on initial commit
current_msg=$(git log -1 --pretty=%B)
if [[ "$current_msg" == *"Initial Commit"* ]]; then
    echo "❎ Skipping Initial Commit..."
    git rebase --continue
    exit 0
fi

# Amend commit message and continue rebase
commit_msg_file="$HOME/Desktop/commit_message_file_with_weird_and_long_name_to_avoid_accidental_commits.txt"

if [[ -s "$commit_msg_file" ]]; then
    echo "Found $commit_msg_file, amending commit..."

    # Force LF line endings (exit if dos2unix command fails)
    dos2unix $commit_msg_file >/dev/null 2>&1 || exit 1

    # Amend while preserving dates and author (exit if commit command fails)
    author_date=$(git log -1 --format=%aD)
    GIT_COMMITTER_DATE="$author_date" \
        git commit --amend -F $commit_msg_file --date="$author_date" >/dev/null || exit 1

    # Continue the rebase
    git rebase --continue
fi

# Reset commit message file if it reaches here (Hopefully it does by gods grace)
echo "" >"$commit_msg_file"

# Copy the prompt to clipboard
cat <<'EOF' | clip
You are generating a git commit message.

Strict rules:
- First line: max 75 characters
- Use imperative mood (e.g., "fix", "add", "remove")
- No trailing period
- Blank line after first line
- Then bullet points using "- "
- Focus only on WHAT changed and WHY
- Be specific, avoid vague phrases like "update code"
- Do NOT mention "diff", "patch", or "above code"
EOF

# Generate diff file and check if empty
diff_file="$HOME/Desktop/git-diff.txt"
git show --format= --unified=3 HEAD >"$diff_file"

if [[ ! -s "$diff_file" ]]; then

    echo "======================================================"
    echo "Diff file empty, Skipping..."
    echo "======================================================"
    git rebase --continue
    exit 0
fi

# Copy diff file to clipboard using PowerShell
win_diff_path=$(cygpath -w "$diff_file")
powershell.exe -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; \$col = New-Object System.Collections.Specialized.StringCollection; \$col.Add('${win_diff_path}') | Out-Null; [System.Windows.Forms.Clipboard]::SetFileDropList(\$col)"

echo "======================================================"
echo "✅ Prompt and $diff_file copied to clipboard!"
echo "======================================================"

exit 0
