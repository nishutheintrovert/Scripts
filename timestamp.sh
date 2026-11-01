#!/usr/bin/env bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

# Print colored help message on every run
script_name="${0##*[\\/]}"
echo -e "${CYAN}--------------------------------------------------------------${RESET}"
echo -e "${YELLOW}Usage:${RESET}"
echo -e "  ${GREEN}${script_name}${RESET}                  ${WHITE}: Interactive mode (copies Discord timestamp)${RESET}"
echo -e "  ${GREEN}${script_name} <ts1> [ts2 ...]${RESET} ${WHITE}: Convert 10-digit (s) or 13-digit (ms) timestamps to human readable${RESET}"
echo -e "${CYAN}--------------------------------------------------------------${RESET}"

# Convert and print timestamps if positional arguments are provided
if [[ $# -gt 0 ]]; then
    for arg in "$@"; do
        if [[ "$arg" =~ ^([0-9]{10}|[0-9]{13})$ ]]; then
            ms=".000"
            sec="$arg"
            if [[ ${#arg} -eq 13 ]]; then
                ms=".${arg:10:3}"
                sec="${arg:0:10}"
            fi
            printf -v readable '%(%Y-%m-%d %H:%M:%S)T' "$sec"
            echo -e "${CYAN}${arg}${RESET} : ${GREEN}${readable}${ms}${RESET}"
        else
            echo -e "${CYAN}${arg}${RESET} : ${RED}Error: Malformed input${RESET}"
        fi
    done
    exit 0
fi

# Get current timestamp and datetime components using printf
printf -v current_ts '%(%s)T' -1
printf -v cur_datetime '%(%Y %m %d %H %M %S)T' "$current_ts"
read cur_year cur_month cur_day cur_hour cur_min cur_sec <<<"$cur_datetime"
echo -n "<t:$current_ts:R>" | clip.exe

echo -e "${GREEN}Current Unix timestamp copied to clipboard:${RESET} ${MAGENTA}<t:$current_ts:R>${RESET}"
echo -e "${CYAN}--------------------------------------------------------------${RESET}"
echo -e "${YELLOW}Enter Date (Press Enter for current value)${RESET}"

echo -ne "${CYAN}Year (YYYY) ${YELLOW}[$cur_year]${CYAN}: ${RESET}"
read year
year=${year:-$cur_year}

echo -ne "${CYAN}Month (1-12) ${YELLOW}[$cur_month]${CYAN}: ${RESET}"
read month
month=${month:-$cur_month}

echo -ne "${CYAN}Day (1-31) ${YELLOW}[$cur_day]${CYAN}: ${RESET}"
read day
day=${day:-$cur_day}

echo -ne "${CYAN}Hour (0-23) ${YELLOW}[$cur_hour]${CYAN}: ${RESET}"
read hour
hour=${hour:-$cur_hour}

echo -ne "${CYAN}Minute (0-59) ${YELLOW}[$cur_min]${CYAN}: ${RESET}"
read minute
minute=${minute:-$cur_min}

echo -ne "${CYAN}Second (0-59) ${YELLOW}[$cur_sec]${CYAN}: ${RESET}"
read second
second=${second:-$cur_sec}

# Format datetime
formatted="$year-$month-$day $hour:$minute:$second"

# Convert to timestamp
ts=$(date -d "$formatted" +%s 2>/dev/null)

if [[ -z "$ts" ]]; then
    echo -e "${RED}Invalid date/time. Clipboard still contains current timestamp.${RESET}"
    exit 1
fi

# Override clipboard
echo -n "<t:$ts:R>" | clip.exe

echo -e "${CYAN}--------------------------------------------------------------${RESET}"
echo -e "${GREEN}Unix timestamp:${RESET} ${MAGENTA}<t:$ts:R>${RESET} ${GREEN}copied to clipboard!${RESET}"
echo -e "${CYAN}--------------------------------------------------------------${RESET}"
