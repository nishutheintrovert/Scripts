#!/bin/bash

# API Keys and URLs
API_KEY="NjY3ODM4YWM2ZGM5NjdlZjk4YTVjYzUyLmgyOG5rU1V4eUNJd3N2cVIxbzBKQzVmVXNZMVdtQ0tz"
TIME_BEST_URL="https://api.monkeytype.com/users/personalBests?mode=time"
WORDS_BEST_URL="https://api.monkeytype.com/users/personalBests?mode=words"

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

# Fetch time bests
time_best_response=$(api_request "$TIME_BEST_URL" "$API_KEY")

# Fetch words bests
words_best_response=$(api_request "$WORDS_BEST_URL" "$API_KEY")

clear -x

# Print header
echo -e "\\n${YELLOW}Personal best on ${BLUE}MonkeyType${RESET}\\n"
printf "${WHITE}%-20s ${RED}%-20s ${GREEN}%-20s${RESET}\n" "Mode" "Speed (WPM)" "Accuracy (%)"

# Print words bests
for words in 10 25 50; do
    wpm=$(echo $words_best_response | jq -r ".data.\"$words\"[0].wpm")
    acc=$(echo $words_best_response | jq -r ".data.\"$words\"[0].acc")
    printf "${WHITE}%-20s ${RED}%-20s ${GREEN}%-20s${RESET}\n" "$words Words" "$wpm" "$acc"
done

printf "${WHITE}%-20s ${RED}%-20s ${GREEN}%-20s${RESET}\n" "100 Words" "$(echo $words_best_response | jq -r '.data."100"[1].wpm')" "$(echo $words_best_response | jq -r '.data."100"[1].acc')" # 100[0] fetching wrong array

echo ""

# Print time bests
for duration in 15 30 60 120; do
    wpm=$(echo $time_best_response | jq -r ".data.\"$duration\"[0].wpm")
    acc=$(echo $time_best_response | jq -r ".data.\"$duration\"[0].acc")
    printf "${WHITE}%-20s ${RED}%-20s ${GREEN}%-20s${RESET}\n" "$duration Seconds" "$wpm" "$acc"
done

# Only for debugging
# echo $time_best_response > /d/Desktop/time.json && start /d/Desktop/time.json
# echo $words_best_response > /d/Desktop/words.json && start /d/Desktop/words.json
