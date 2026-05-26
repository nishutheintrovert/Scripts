#!/usr/bin/env bash

# Find dependencies in the system PATH
MouseMover_Path=$(command -v mousemover.exe)

if [ -z "$MouseMover_Path" ]; then
    echo "Error: mousemover.exe not found in PATH."
    read -rsn1
    exit 1
fi

# Minimize mintty
printf '\e[2t'

# Save current position to load later
position=$($MouseMover_Path position)
# Use click sequence to send selected wallpaper to connected mobile in wallpaper engine
$MouseMover_Path rightclick
$MouseMover_Path moveby 100x180
read -t 0.3
$MouseMover_Path click
$MouseMover_Path moveby 200x10
read -t 0.3
$MouseMover_Path click
$MouseMover_Path moveto 1304x424
read -t 0.3
$MouseMover_Path click
$MouseMover_Path moveby 0x-40
read -t 0.3
$MouseMover_Path click
$MouseMover_Path moveto 1580x587
read -t 0.3
$MouseMover_Path click

# Extract X and Y coordinates
x_pos="${position%x*}"
y_pos="${position#*x}"

# Add 213 to the X coordinate
x_pos=$((x_pos + 213))

# Recombine and execute the final move
$MouseMover_Path moveto "${x_pos}x${y_pos}"
