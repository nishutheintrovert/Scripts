#!/usr/bin/env bash

# Define your input file here
INPUT_FILE="log.txt"

# Check if the file exists before running
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Cannot find $INPUT_FILE"
    exit 1
fi

echo "Splitting $INPUT_FILE into separate log files..."

awk '
# When we hit the start line
/^----------Downloading [0-9]+--------/ {
    # Extract just the numbers from the line to use as the ID
    match($0, /[0-9]+/)
    id = substr($0, RSTART, RLENGTH)

    # Define the output file name
    outfile = id ".log"

    # Set a flag that we are currently writing
    writing = 1
}

# If the writing flag is active, append the current line to the output file
writing == 1 {
    print $0 >> outfile
}

# When we hit the finish line
/^-------------Download finished-----------/ {
    # Close the file and turn off the writing flag
    if (writing == 1) {
        close(outfile)
        writing = 0
    }
}
' "$INPUT_FILE"

echo "Done! Check your directory for the new log files."
