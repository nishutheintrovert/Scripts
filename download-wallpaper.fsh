#!/usr/bin/env bash

# Find dependencies in the system PATH
VBS_PATH=$(command -v sendkeys.vbs)
MouseMover_Path=$(command -v mousemover.exe)

if [ -z "$VBS_PATH" ]; then
    echo "Error: sendkeys.vbs not found in PATH."
    read -rsn1
    exit 1
elif [ -z "$MouseMover_Path" ]; then
    echo "Error: mousemover.exe not found in PATH."
    read -rsn1
    exit 1
fi

# Minimize mintty
printf '\e[2t'

# Convert the located path to a Windows format so wscript.exe can read it
WIN_VBS_PATH=$(/usr/bin/cygpath -w "$VBS_PATH")

# Click to copy the link in wallpaper engine
$MouseMover_Path click
read -t 0.2

# Execute the specific sequence using explicit window focus
wscript.exe //B "$WIN_VBS_PATH" "FOCUS:Wallpaper Engine Workshop Downloader" "WAIT:500" "^v" "WAIT:200" "{ENTER}" "WAIT:200" "FOCUS:Wallpaper UI"
