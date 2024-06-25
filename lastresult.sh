#!/bin/bash

# API Key and URL
API_KEY="NjY3ODM4YWM2ZGM5NjdlZjk4YTVjYzUyLmgyOG5rU1V4eUNJd3N2cVIxbzBKQzVmVXNZMVdtQ0tz"
LAST_RESULT_URL="https://api.monkeytype.com/results/last"

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

    # Make the API request with curl, following redirects (-L)
    response=$(curl -sS -L -X GET -H "Authorization: ApeKey $key" "$url")

    # Return the response
    echo "$response"
}

# Function to calculate and print typing metrics using awk
function calculate_typing_metrics() {
    local wpm="$1"
    local characters_typed="$2"

    # Calculate cpm, cps, and ms per character using awk
    awk -v wpm="$wpm" -v characters_typed="$characters_typed" '
    BEGIN {
        cpm = wpm * 5;
        cps = cpm / 60.0;
        ms_per_character = (1.0 / cps) * 1000.0;

        printf "'$CYAN'Milliseconds per character : %.0f ms\n'$RESET'", ms_per_character;
        printf "Characters per minute (CPM): %.0f\n", cpm;
        printf "Characters per second (CPS): %.8f\n", cps;
    }'
}

# Fetch last result
last_result_response=$(api_request "$LAST_RESULT_URL" "$API_KEY")

# Extract values from last result
last_wpm=$(echo "$last_result_response" | jq -r '.data.wpm')
last_accuracy=$(echo "$last_result_response" | jq -r '.data.acc')
last_characters=$(echo "$last_result_response" | jq -r '.data.charStats[0]')
last_duration=$(echo "$last_result_response" | jq -r '.data.testDuration')
last_username=$(echo "$last_result_response" | jq -r '.data.name')
last_mode=$(echo "$last_result_response" | jq -r '.data.mode')
last_mode2=$(echo "$last_result_response" | jq -r '.data.mode2')

clear -x

# Print last result details
echo -e "${RED}Words per minute (WPM)     : $last_wpm${RESET}"
echo -e "${GREEN}Accuracy                   : $last_accuracy${RESET}"

# Print calculated output using function
calculate_typing_metrics "$last_wpm" "$last_characters"

# Print minor details
echo -e "Test Duration              : $last_duration"
echo -e "Characters Typed           : $last_characters"
echo -e "User Name                  : $last_username"
echo -e "Mode                       : $last_mode"
echo -e "Mode 2                     : $last_mode2"

# Only for debugging
# echo $last_result_response > /d/Desktop/lastresult.json && start /d/Desktop/lastresult.json
