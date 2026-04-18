#!/usr/bin/env bash
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

# To reduce file size of nilu didi's camera's photos to fit removebg's limit
magick 1.jpg -resize 8000x6000 -strip resized_1.jpg

# To process files one by one using remove bg
for file in ./Pics/*.jpg; do
    echo "Processing $file..."
    removebg "$file"
    sleep 20
done

# Exit on error, unset variable, or pipe failure, use wisely
set -euo pipefail

# Move to the directory where this script resides
cd "$(dirname "$0")" || exit 1

# Removes the symbolic reference to the default branch (removes extra origin/HEAD)
git remote set-head origin --delete

# Crop image from svg
magick -background none -density 300 "Blossom_Dark.svg" -fill white -colorize 100% -resize "512x512^" -gravity center -extent 512x512 "output.png"

# Convert png to icon with transparency
magick "input.png" -background none -alpha on -define icon:auto-resize=256,128,64,48,32,16 -compress none "output.ico"

# Remove audio track 2 (mic) from obs recorded file
ffmpeg -i "input.mp4" -map 0 -map -0:a:1 -c copy "output.mp4"

# Set all black pixels to be transparent
magick input.png -fuzz 5% -transparent black output.png

# Set all white pixels to be transparent
magick output.png -fuzz 5% -transparent white output.png

# Upscale image to 200% without losing quality and accuracy
magick input.png -filter Lanczos -resize 200% -adaptive-sharpen 0x2 output.png

# Convert vector based pdf to ppm then ppm to png
pdftoppm -r 300 "input.pdf" "output"
magick "output-000001.ppm" "output.png"

# Convert rectangular images to be square shaped
magick input.png -gravity center -background white -extent "%[fx:max(w,h)]x%[fx:max(w,h)]" output.png

# Add white padding to image
magick input.png -gravity center -background white -extent 1024x1024 output.png

# To get exact return code of pipeline
echo "${PIPESTATUS[*]}"

# examples of using exec
exec attributes.sh   # Runs attributes.sh in current session and exits
(exec attributes.sh) # Runs attributes.sh in new session and exits

# see all exif information on terminal
exiftool image.jpg

# remove exif information from image
exiftool -all= image.jpg

# cut at colon delimeter and select field 1
cut -d: -f1

# trim newlines and replace them with null character
tr '\n' '\0'
