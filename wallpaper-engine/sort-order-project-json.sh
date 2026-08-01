#!/usr/bin/env bash

# Check if the file exists
if [[ ! -f "project.json" ]]; then
    echo "Error: project.json not found."
    exit 1
fi

# Create a backup just in case
cp project.json project.json.bak
echo "Backup created at project.json.bak"

# Parse, sort, and rebuild the JSON object
jq '.general.properties |= (
  to_entries 
  | sort_by(.value.order) 
  | to_entries 
  | map(.value.value.order = (.key + 100)) 
  | map(.value) 
  | from_entries
)' project.json >tmp_project.json

# Overwrite the original file with the fixed version
mv tmp_project.json project.json
echo "Success! Properties have been re-indexed sequentially starting from 100."
