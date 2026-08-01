#!/usr/bin/env bash

# Xterm escape sequence to minimize Mintty
printf '\e[2t'

# Sleep 0.5 seconds to avoid race conditions with window minimization
read -t 0.5

# Call PowerShell to simulate the keystrokes
powershell.exe -NoProfile -Command "
    Add-Type -AssemblyName System.Windows.Forms;
        \$text = Get-Clipboard;

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
