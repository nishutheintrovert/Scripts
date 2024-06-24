#!/bin/bash
exit #Syntax file, do not execute

#To rename .txt files to .sh files
for file in *.txt; do mv "$file" "${file%.txt}.sh"; done

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
RESET='\033[0m'

echo -e ${RESET} # Use RESET variable's data in command
echo -e ${CYAN}Text${RESET}
echo -e ${MAGENTA}Text${RESET}
echo -e ${RED}Text${RESET}
echo -e ${GREEN}Text${RESET}
echo -e ${WHITE}Text${RESET}

echo -e "${MAGENTA}************************************************************************${RESET}"

Command >/dev/null 2>&1 # stdout > null, stderr > null
Command >/dev/null      # stdout > null
Command 2>/dev/null     # stderr > null
Command 1>output.txt    # stdout > output.txt
Command 2>output.txt    # stderr > output.txt

png2ico() {
    local i="${1}" o="${2:-${1:r}.ico}" s="${png2ico_size:-256}"
    convert -resize x${s} -gravity center -crop ${s}x${s}+0+0 "$i" -colors 256 -background transparent "$o"
}
png2ico image.png
