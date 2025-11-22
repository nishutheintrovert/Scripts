#!/bin/bash

# Print help message if no argument is provided
#if [ -z "$1" ]; then
#    echo "Usage: $0 <folder>"
#    exit 1
#fi
#DIR="$1"

# Directory containing images (you can pass as $1)
DIR="${1:-.}"

# Remove trailing slash if user passes "./Converted/"
DIR="${DIR%/}"

# Create output folder inside DIR
mkdir -p "$DIR/Processed"

# Loop through supported image formats
for file in "$DIR"/*.{jpg,JPG,jpeg,JPEG,png,PNG}; do
    # Skip non-existing globs
    [ -e "$file" ] || continue

    echo "Processing: $file"

    # Extract filename without extension
    base=$(basename "$file")
    name="${base%.*}"

    # Get image dimensions using ImageMagick identify
    read width height <<<$(magick identify -format "%w %h" "$file")

    # Select the DIM as the smaller dimension
    if ((width < height)); then
        DIM=$width
    else
        DIM=$height
    fi

    PAD=0
    C=$((DIM / 2))

    # Output file inside Converted/Processed/
    OUT="$DIR/Processed/${name}.png"

    echo "width=$width height=$height DIM=$DIM output=$OUT"

    # Run ImageMagick command
    magick "$file" \
        -gravity center \
        -resize "${DIM}x${DIM}^" \
        -extent ${DIM}x${DIM} \
        \( -size ${DIM}x${DIM} xc:black -fill white +antialias -draw "circle $C,$C $C,$PAD" \) \
        -alpha off -compose CopyOpacity -composite \
        "$OUT"

    echo "Saved: $OUT"
done

echo "Done."
