#!/usr/bin/env bash
code $0
exit 1 #Syntax file, do not execute

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

# Create transparent icon
magick -size 256x256 xc:transparent ./transparent.ico

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

# make .fsh files run without --login and -i flags globally
assoc .fsh=fast_shell_file
ftype fast_shell_file="C:\Program Files\Git\usr\bin\mintty.exe" -w max -e /usr/bin/bash --noprofile --norc "%1" %*

# revert above commands
assoc .fsh=
ftype fast_shell_file="C:\Program Files\Git\bin\bash.exe" --login -i "%1" %*

# Minimize current (mintty) terminal
printf '\e[2t'

# Restore current (mintty) terminal
printf '\e[1t'

# i dont know why this is here but there you go
echo "✅ ❎"
echo "✔ ✖"
echo "❗ ‼ ⚠"
echo "⛔ 🛑 ❌ 🚫"

# Extract basename of pwd
$(basename "$PWD")

# Delete binary files
find . -type f ! -path '*/.git/*' -print0 | xargs -0r file --mime-encoding | grep 'binary' | cut -d':' -f1 | xargs -r -d '\n' rm -f

# Filter text files
find . -type f ! -path '*/.git/*' -print0 | xargs -0r file --mime-encoding | grep -v 'binary' | cut -d':' -f1

# Dry-run delete text files with no shebang
find . -type f ! -path '*/.git/*' -print0 | xargs -0r file --mime-encoding | grep -v 'binary' | cut -d':' -f1 | xargs -r -d '\n' sh -c 'for f do [ "$(head -c 2 "$f")" != "#!" ] && echo "Would delete: $f"; done' sh

# Delete text files with no shebang
find . -type f ! -path '*/.git/*' -print0 | xargs -0r file --mime-encoding | grep -v 'binary' | cut -d':' -f1 | xargs -r -d '\n' sh -c 'for f do [ "$(head -c 2 "$f")" != "#!" ] && rm -v "$f"; done' sh

# Remove file from repository's history
git filter-repo --invert-paths --force \
    --path dummy.txt

# Rename file from repository's history
git filter-repo --path-rename full/path/to/old_file:full/path/to/new_file

assoc .fsh=fshfile
ftype fshfile
ftype fshfile="C:\Program Files\Git\bin\bash.exe" --noprofile --norc "%1" %*
ftype fshfile="C:\Program Files\Git\bin\bash.exe" --noprofile --norc -O expand_aliases off "%1" %*

# Compare contents of files (Switch files to find unique in smaller-list.txt)
grep -v -F -x -f smaller-list.txt bigger-list.txt >list-not-in-smaller-but-in-bigger.txt

# Print all unique entries in both files
sort smaller-list.txt bigger-list.txt | uniq -u >all-unique-items.txt

# Detailed summery of unique items in both
comm -3 <(sort smaller-list.txt) <(sort bigger-list.txt) >all-unique-items.txt

# Open explorer window for each first level directories
find ./ -mindepth 1 -maxdepth 1 -type d | while read -r f; do explorer.exe "$(cygpath -w "$f")"; done

# Combine two icons into one using -gravity
combineicons() {
    if [ "$#" -ne 4 ]; then
        echo "Usage: combine2ico <background-image> <foreground-image> <size> <output-name>"
        return 1
    fi

    local bg="$1"
    local fg="$2"
    local size="$3"
    local out="$4"

    # Use ImageMagick 7 to composite, resize, crop, and convert to .ico
    magick "$bg" "$fg" -gravity center -composite \
        -resize x${size} -gravity center -crop ${size}x${size}+0+0 +repage \
        -colors 256 -background transparent "$out"

    echo "Success! Saved as $out in the current directory."
}

# If argument passed, use it, if not passed, take current directry as argument
if [ -n "$1" ]; then
    path=$1
else
    path=./
fi
# Shorter version
path="${1:-./}"

# Clock for DesktopClock
{dddd}, {dd} {MMMM}, {yyyy}  ♥  {HH:mm:ss  [hh:mm tt]}
