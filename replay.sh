#!/usr/bin/env bash

#	Author	: Nishikant Kanunje
#	Date	: 08/09/2026
#	Purpose	: Replay the exact touch sequence on rooted device using adb

# adb shell getevent
# - Touch once and note event number, ctrl+c to stop recording
# eg. /dev/input/event2, /dev/input/event4
# adb shell "cat /dev/input/eventX > /sdcard/full_run.bin"
# - Hit ctrl+c to stop
# adb shell "cat /sdcard/full_run.bin > /dev/input/eventX"

#!/usr/bin/env bash

# --- CONFIGURATION ---
EVENT_NODE="/dev/input/eventX" # Fill event number
RECORDING_FILE="/sdcard/full_run.bin"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

COUNTER=0

# --- EXECUTION ---
echo -e "${GREEN}Starting full-run replay loop. Press Ctrl+C to stop.${RESET}"

while true; do
    echo "Playing recorded sequence..."
    adb shell "cat $RECORDING_FILE > $EVENT_NODE"

    # Safety delay efore the next loop starts
    sleep 2

    ((COUNTER++))
    echo -e "Loops completed: ${WHITE}$COUNTER${RESET}"
done
