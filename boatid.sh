#!/bin/bash

# Define ANSI color variables
RED='\033[0;31m'
GREEN='\033[0;92m'
CYAN='\033[0;96m'
RESET='\033[0m'

# 1. Pipeline: Run svcl -> Strip BOM -> Parse with jq
# MSYS_NO_PATHCONV=1 ensures '/sjson' stays intact.
# sed '1s/^\xEF\xBB\xBF//' snips the UTF-8 BOM right out of the data stream.
BOAT_ID=$(MSYS_NO_PATHCONV=1 "C:\Tools\svcl-x64\svcl.exe" /sjson | sed '1s/^\xEF\xBB\xBF//' | jq -r '.[] | select(."Device Name" == "boAt IM-1000D" and ."Type" == "Device" and ."Direction" == "Render") | ."Item ID"')

# 2. Check if we actually got a valid ID.
if [ -z "$BOAT_ID" ] || [ "$BOAT_ID" == "null" ]; then
    echo -e "${RED}Error: Device 'boAt IM-1000D' not found or failed to parse the JSON stream.${RESET}"
    exit 1
fi
echo -e "${GREEN}Found boAt IM-1000D ID: ${CYAN}$BOAT_ID${RESET}"

# 3. Construct the custom command.
CUSTOM_CMD='@^N=run | "C:\Tools\svcl-x64\svcl.exe" /stdout /SwitchDefault "{0.0.0.00000000}.{0f90db0a-b6dd-4dcf-a030-56dfe84f9121}" "'$BOAT_ID'" "all" | 2'

# 4. Copy directly to clipboard along with newline.
echo "$CUSTOM_CMD" | clip

echo -e "${GREEN}Command copied to clipboard${RESET}"
