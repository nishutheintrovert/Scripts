#!/usr/bin/env bash

# Prompt for the text
read -p "Enter the text to type: " secret_text
echo ""

# Xterm escape sequence to minimize Mintty
printf '\e[2t'

# Pause for 3 seconds using the built-in read timeout
read -t 3

# Export as an environment variable
export SECRET_TEXT="$secret_text"

# Call PowerShell to simulate the keystrokes
powershell.exe -NoProfile -Command "
    Add-Type -AssemblyName System.Windows.Forms;
    \$text = \$env:SECRET_TEXT;

    if (\$null -ne \$text) {
        foreach (\$char in \$text.ToCharArray()) {
            if (\$char -match '[\+\^\%\~\(\)\{\}\[\]]') {
                [System.Windows.Forms.SendKeys]::SendWait(\"{\$char}\")
            } else {
                [System.Windows.Forms.SendKeys]::SendWait(\$char.ToString())
            }
            Start-Sleep -Milliseconds 50
        }
    }
"

# Xterm escape sequence to restore the window
# printf '\e[1t'
