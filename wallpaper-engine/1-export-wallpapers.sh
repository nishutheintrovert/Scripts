#!/usr/bin/env bash

#    Author    : Nishikant Kanunje
#    Date    : 19/05/2026
#    Purpose    : Extract insalled wallpaper packs list from wallpapers directory, create a diff file for differences in old and new wallpapers.txt

# Handle first-run scenario so diff doesn't break
if [ -f ./wallpapers.txt ]; then
    mv ./wallpapers.txt ./old-wallpapers.txt
else
    touch ./old-wallpapers.txt
fi

for d in /C/Program\ Files\ \(x86\)/Steam/steamapps/workshop/content/431960/*; do
    if [ -d "$d" ]; then
        echo "https://steamcommunity.com/sharedfiles/filedetails/?id=${d##*/}"
    fi
done | sort >./wallpapers.txt

# Run the diff and extract the changes
changes=$(diff -u ./old-wallpapers.txt ./wallpapers.txt | grep -E "^[-+]https")

# Only append to diff.txt if changes were actually found
if [ -n "$changes" ]; then
    {
        printf "Date: %(%Y-%m-%d___%H:%M:%S)T\n" -1
        echo "$changes"
        echo ""
    } >>./diff.txt
fi

# Clean up the old file
rm -f ./old-wallpapers.txt
