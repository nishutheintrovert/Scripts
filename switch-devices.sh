#!/usr/bin/env bash

# Define ANSI color variables
RED='\033[0;31m'
GREEN='\033[0;92m'
CYAN='\033[0;96m'
RESET='\033[0m'

# 1. Pipeline: Run svcl -> Strip BOM
# MSYS_NO_PATHCONV=1 ensures '/sjson' stays intact (no more needed)
# sed '1s/^\xEF\xBB\xBF//' strips the UTF-8 BOM from the stream
JSON_DATA=$("C:\Tools\svcl-x64\svcl.exe" //sjson | tr -d '\r' | sed '1s/^\xEF\xBB\xBF//')

# 2. Parse with jq for both devices
# Filtering by "Type" == "Device" and "Direction" == "Render" ensures we grab the actual speakers, not subunits or applications
BOAT_ID=$(echo "$JSON_DATA" | jq -r '.[] | select(."Device Name" == "boAt IM-1000D" and ."Type" == "Device" and ."Direction" == "Render") | ."Item ID"')
SPEAKER_ID=$(echo "$JSON_DATA" | jq -r '.[] | select(."Device Name" == "Realtek(R) Audio" and ."Type" == "Device" and ."Direction" == "Render") | ."Item ID"')

# 3. Check if we actually got valid IDs
if [ -z "$BOAT_ID" ] || [ "$BOAT_ID" == "null" ]; then
    echo -e "${RED}Error: Device 'boAt IM-1000D' not found or failed to parse the JSON stream.${RESET}"
    read -rsn1
    exit 1
fi

if [ -z "$SPEAKER_ID" ] || [ "$SPEAKER_ID" == "null" ]; then
    echo -e "${RED}Error: Device 'Realtek(R) Audio' not found or failed to parse the JSON stream.${RESET}"
    read -rsn1
    exit 1
fi

echo -e "${GREEN}Found boAt IM-1000D ID: ${CYAN}$BOAT_ID${RESET}"
echo -e "${GREEN}Found Realtek(R) Audio ID: ${CYAN}$SPEAKER_ID${RESET}"

# 4. Construct the commands
CUSTOM_CMD=$(printf '"C:\Tools\svcl-x64\svcl.exe" /stdout /SwitchDefault "%s" "%s" "all"' "$SPEAKER_ID" "$BOAT_ID")
HoeKey_CMD="@^N=run | $CUSTOM_CMD | 2"

# 5. Echo terminal command on stdout
echo ""
echo ""
echo "$CUSTOM_CMD"
echo ""
echo ""

# 6. Copy hoekey config command to clipboard
printf '%s' "$HoeKey_CMD" | clip.exe

echo -e "${GREEN}HoeKey config command copied to clipboard!${RESET}"
