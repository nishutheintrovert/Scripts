#!/bin/bash

# API Key and URL
API_KEY="$MonkeyType_API_Key"
RESULTS_URL="https://api.monkeytype.com/results"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

# Function to make API request and handle response
function api_request() {
    local url="$1"
    local key="$2"
    local timestamp="$3"

    # Make the API request with curl, following redirects (-L)
    response=$(curl -sS -L -X GET -H "Authorization: ApeKey $key" "$url?onOrAfterTimestamp=$timestamp")

    # Return the response
    echo "$response"
}

# Function to search and display results in a tabular format
function display_results() {
    local results="$1"
    clear -x
    # Print header
    echo -e "\\n${YELLOW}Results on ${BLUE}MonkeyType${RESET}\\n"
    printf "${WHITE}%-25s ${RED}%-20s ${GREEN}%-20s ${YELLOW}%-20s ${RESET}\n" "Date" "Speed (WPM)" "Accuracy (%)" "Timestamp"

    # Process, sort, and print each result
    echo "$results" | jq '.data | sort_by(.timestamp) | .[:10]' | jq -c '.[]' | while IFS= read -r item; do
        local timestamp=$(echo "$item" | jq -r '.timestamp')
        local wpm=$(echo "$item" | jq -r '.wpm')
        local accuracy=$(echo "$item" | jq -r '.acc')

        # Convert timestamp to human-readable date
        local date=$(date -d @"$((timestamp / 1000))" '+%d %b %Y %H:%M:%S')

        # Print the result in tabular form
        printf "${WHITE}%-25s ${RED}%-20s ${GREEN}%-20s ${YELLOW}%-20s ${RESET}\n" "$date" "$wpm" "$accuracy" "$timestamp"
    done
}

# Check if the date is provided as an argument
if [ -z "$1" ]; then
    echo -e "${RED}Error: No date provided.${RESET}"
    echo "Usage: $0 'DD MMM YYYY HH:MM:SS'"
    exit 1
fi

# Convert the argument date to a Unix timestamp in milliseconds
search_timestamp=$(date -d "$1" +%s%3N)

# Fetch results from API with the specified parameters
results_response=$(api_request "$RESULTS_URL" "$API_KEY" "$search_timestamp")

# Call the function to display results
display_results "$results_response"

# Only for debugging
# echo "$results_response" > /d/Desktop/results.json && start /d/Desktop/results.json
