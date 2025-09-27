#!/bin/bash
# --- Format shell scripts ---
echo "Formatting shell scripts"
shfmt -l -w -i=4 -ci -ln=bash ./
