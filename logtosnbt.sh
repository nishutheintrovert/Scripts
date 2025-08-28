#!/bin/bash

INPUT="/c/Users/nishi/AppData/Roaming/.minecraft/instances/Fabric-1.21.4/logs/latest.log"
OUTPUT="/d/Desktop/Villager.txt"

if [[ ! -f "$INPUT" ]]; then
    echo "Input file not found: $INPUT"
    exit 1
fi

# Grep with case-insensitive search and strip CR if needed
grep -i "has the following entity data:" "$INPUT" | tr -d '\r' >"$OUTPUT"
