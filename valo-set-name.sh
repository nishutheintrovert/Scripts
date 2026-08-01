#!/bin/bash

# ==============================================================================
#                                CONFIGURATION
# ==============================================================================
# Riot Client Path
RIOT_CLIENT_PATH="C:\Riot Games\Riot Client\RiotClientServices.exe"

# Account Credentials (We'll use num to append as suffix after base)
USERNAME_BASE="saiyankakarotontop"
PASSWORD_BASE="saiyankakarotontop"

# Riot ID Creation (Ensure your base + input doesn't exceed riot's naming 16#5 limits)
RIOT_NAME="GGEZ"
RIOT_TAG_BASE="IDN"
# ==============================================================================

# 1. Ask the user for the number/suffix
read -p "Enter the account number or suffix: " num

echo "Using input: $num"
echo "Riot name will be: ${RIOT_NAME}#${RIOT_TAG_BASE}${num}"

# 2. Launch Riot Client
echo "Launching Riot Client..."
powershell.exe -command "Start-Process -FilePath '${RIOT_CLIENT_PATH}'"

# 3. Wait for Riot Client to open
echo "Waiting 3 seconds for initial load..."
sleep 3

# Loop to check if Riot Client is open and activate it
while true; do
    status=$(powershell.exe -command "(New-Object -ComObject WScript.Shell).AppActivate('Riot Client')" | tr -d '\r')

    if [ "$status" = "True" ]; then
        echo "Riot Client is open and active!"
        break
    else
        echo "Riot Client not found yet. Waiting 1 more seconds..."
        sleep 1
    fi
done

# Give the window a second to fully render after coming to focus
sleep 2

# 4. Helper functions for Keyboard Input
paste_text() {
    local text="$1"
    echo -n "$text" | clip.exe
    sleep 0.2
    powershell.exe -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait('^v')"
    sleep 0.2
}

send_key() {
    local key="$1"
    powershell.exe -command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait('${key}')"
    sleep 0.2
}

# 5. Execute the automation sequence

# Username (Username text field is already highlighted)
paste_text "${USERNAME_BASE}${num}"

# Password (Use TAB to navigate)
send_key "{TAB}"
paste_text "${PASSWORD_BASE}${num}"

# Submit (Use ENTER to submit the form)
send_key "{ENTER}"

# Wait for login process to finish
sleep 5

# Click terms and service slider
MouseMover moveto 1529x418
sleep 0.2
MouseMover click

# Drag the slider down
MouseMover dragby 0x12
sleep 0.2

# Keyboard input for submit
send_key "{TAB}"
send_key "{TAB}"
send_key "{ENTER}"

# Wait 3
sleep 3

# Click on valorant
neon moveto 546x720
sleep 0.2
neon click

# Click on Play
neon moveto 765x588
sleep 0.2
neon click

# Input name
send_key "{TAB}"
paste_text "${RIOT_NAME}"

# Input tag
send_key "{TAB}"
paste_text "${RIOT_TAG_BASE}${num}"

# Submit
send_key "{ENTER}"

# Sleep 5
sleep 5

# Close the session
# Sleep 5
sleep 5

# Close the session (ALT + F4)
send_key "%{F4}"

echo "Sequence complete!"
exit 0
