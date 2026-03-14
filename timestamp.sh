#!/usr/bin/env bash

# Get current datetime components
read cur_year cur_month cur_day cur_hour cur_min cur_sec <<<$(date "+%Y %m %d %H %M %S")

# Copy current timestamp immediately
current_ts=$(date +%s)
echo -n "<t:$current_ts:R>" | clip.exe

echo "--------------------------------------------------------------"
echo "Current Unix timestamp copied to clipboard: <t:$current_ts:R>"
echo "--------------------------------------------------------------"
echo "Enter Date (Press Enter for current value)"

read -p "Year (YYYY) [$cur_year]: " year
year=${year:-$cur_year}

read -p "Month (1-12) [$cur_month]: " month
month=${month:-$cur_month}

read -p "Day (1-31) [$cur_day]: " day
day=${day:-$cur_day}

read -p "Hour (0-23) [$cur_hour]: " hour
hour=${hour:-$cur_hour}

read -p "Minute (0-59) [$cur_min]: " minute
minute=${minute:-$cur_min}

read -p "Second (0-59) [$cur_sec]: " second
second=${second:-$cur_sec}

# Format datetime
formatted=$(printf "%04d-%02d-%02d %02d:%02d:%02d" \
    "$year" "$month" "$day" "$hour" "$minute" "$second")

# Convert to timestamp
ts=$(date -d "$formatted" +%s 2>/dev/null)

if [[ -z "$ts" ]]; then
    echo "Invalid date/time. Clipboard still contains current timestamp."
    exit 1
fi

# Override clipboard
echo -n "<t:$ts:R>" | clip.exe

echo "--------------------------------------------------------------"
echo "Unix timestamp: <t:$ts:R> copied to clipboard!"
echo "--------------------------------------------------------------"
