#!/usr/bin/env bash

# Exit cleanly if the user presses Ctrl+C
trap 'exit 130' INT

# Configuration
LOG_FILE="we_dependency_updates.log"
BASE_DIR='C:\Program Files (x86)\Steam\steamapps\workshop\content\431960'
BATCH_SIZE=11

# Verification: Ensure the log file actually exists before starting
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: Log file '$LOG_FILE' not found in the current directory!"
    exit 1
fi

count=0

echo "Processing IDs from $LOG_FILE..."

# Stream IDs directly using process substitution to keep stdin open for the pause prompt
while IFS= read -r id || [[ -n "$id" ]]; do

    # Skip line if it is empty
    [[ -z "$id" ]] && continue

    # Construct the path explicitly using Windows backslashes
    full_path="${BASE_DIR}\\${id}"

    # Launch Explorer in the background
    explorer.exe "$full_path" >/dev/null 2>&1 &

    ((count++))

    # Batch control mechanism
    if ((count % BATCH_SIZE == 0)); then
        # Minimize terminal window size hint (optional terminal command)
        printf '\e[2t'

        echo -n "Opened $count folders. Press [Spacebar] to continue, [q] to quit: "

        while true; do
            # Read directly from the keyboard terminal device
            if ! IFS= read -rsn1 key </dev/tty; then
                echo -e "\nTerminal disconnected or read failed. Breaking loop!"
                break 2
            fi

            if [[ "$key" == " " ]]; then
                echo "" # New line for the next set of outputs
                break
            elif [[ "$key" == "q" || "$key" == "Q" ]]; then
                echo -e "\nQuit key pressed. Exiting script."
                break 2
            fi
        done
    fi

done < <(grep <"$LOG_FILE" "Updated" | cut -d' ' -f4)

echo "Finished processing. Total folders opened: $count"
