#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <script-to-run-as-admin>"
    exit 1
fi

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process 'C:\\Program Files\\Git\\git-bash.exe' -ArgumentList '$1' -Verb RunAs"
