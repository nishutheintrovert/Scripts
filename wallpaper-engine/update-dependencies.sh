#!/usr/bin/env bash

# Define paths
CONFIG_FILE="C:/Program Files (x86)/Steam/steamapps/common/wallpaper_engine/config.json"
WORKSHOP_DIR="C:/Program Files (x86)/Steam/steamapps/workshop/content/431960"

# Target dependencies
OLD_DEP="893418273"
NEW_DEP="3739874654"

# Log file location
LOG_FILE="we_dependency_updates.log"

# Initialize the log file with a starting timestamp
printf "%(--- Wallpaper Engine Dependency Update Log - %Y-%m-%d %H:%M:%S ---)T\n" -1 >"$LOG_FILE"

# Config.json exists?
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: config.json not found at $CONFIG_FILE"
    exit 1
fi

echo "Extracting IDs from 'Audio Visualizer' folder..."

# Extract all the keys (IDs) from "items" objects inside the "Audio Visualizer" folder
mapfile -t ids < <(jq -r '.. | objects | select(.title? == "Audio Visualizer") | .. | objects | select(has("items")?) | .items | keys[]' "$CONFIG_FILE" | tr -d '\r')

if [[ ${#ids[@]} -eq 0 ]]; then
    echo "No IDs found in the Audio Visualizer folder."
    exit 0
fi

echo "Found ${#ids[@]} potential IDs. Scanning projects..."

count=0
updated=0

for id in "${ids[@]}"; do

    project_file="$WORKSHOP_DIR/$id/project.json"

    # Check if the project folder and JSON actually exist in the workshop directory
    if [[ -f "$project_file" ]]; then
        ((count++))

        # Extract the current dependency ID
        current_dep=$(jq -r '.dependency // empty' "$project_file" | tr -d '\r')

        # If it matches our target old dependency, update it
        if [[ "$current_dep" == "$OLD_DEP" ]]; then
            echo "Updating project ID: $id"

            # Log the successful find and intended update
            printf "%([%H:%M:%S] Updated ID: $id)T\n" -1 >>"$LOG_FILE"

            # Create a backup
            cp "$project_file" "${project_file}.bak"

            # Use a temporary file to hold the modified JSON
            tmp_file=$(mktemp)

            # Update the dependency value and output to the temp file
            jq --arg new_dep "$NEW_DEP" '.dependency = $new_dep' "$project_file" >"$tmp_file"

            # Overwrite the original file with the updated temp file
            mv "$tmp_file" "$project_file"
            ((updated++))
        fi
    fi
done

echo "Processed $updated projects inside $WORKSHOP_DIR" >>"$LOG_FILE"
echo "----------------------------------------"
echo "Scanned $count valid project files, updated $updated projects."
echo "Original files backed up with a .bak extension."
echo "Log of updated entries saved to: $LOG_FILE"
