#!/usr/bin/env bash

# Check for ImageMagick
if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick (magick) is not installed."
    exit 1
fi

INPUT_SVG="wallpapers/nix-d-nord.svg"
OUTPUT_IMG="wallpapers/nix-d-nord-seamless.png"
TEMP_BASE="temp_base.png"
TEMP_ROLLED="temp_rolled.png"
TEMP_MASK="temp_mask.png"
TEMP_RESULT="temp_result.png"

echo "Converting SVG to PNG..."
# Convert SVG to PNG. Resizing to 1024x1024 for a reasonable tile size.
# If you want a larger tile, increase the density or resize.
magick "$INPUT_SVG" -resize 1024x1024 "$TEMP_BASE"

WIDTH=$(magick identify -format "%w" "$TEMP_BASE")
HEIGHT=$(magick identify -format "%h" "$TEMP_BASE")
HALF_W=$((WIDTH / 2))
HALF_H=$((HEIGHT / 2))

echo "Creating seamless tile (Crossfade/Overlap method)..."
# This method blends the edges to create a seamless seamless tile.
# It is generally better for random or semi-random textures than mirroring.

# 1. Resize to a tile base size (e.g., 1024x1024)
TILE_SIZE=1024
echo "converting svg to $TILE_SIZE x $TILE_SIZE tile..."
magick "$INPUT_SVG" -resize "${TILE_SIZE}x${TILE_SIZE}^" -gravity center -extent "${TILE_SIZE}x${TILE_SIZE}" "$TEMP_BASE"

WIDTH=$TILE_SIZE
HEIGHT=$TILE_SIZE
HALF_W=$((WIDTH / 2))
HALF_H=$((HEIGHT / 2))

# 2. Roll the image by 50%
magick "$TEMP_BASE" -roll "+${HALF_W}+${HALF_H}" "$TEMP_ROLLED"

# 3. Create a mask (Radial gradient: White center, Black edges)
# We use standard 'radial-gradient:' which goes from center to corners.
# default is white-black, so center=white, corners=black. perfect.
magick -size "${WIDTH}x${HEIGHT}" radial-gradient:white-black "$TEMP_MASK"

# 4. Composite
# dest: ROLLED (Edges of this image are continuous because they come from the center of the original)
# src: BASE (Center of this image is the original center)
# mask: MASK (White center -> show SRC. Black edges -> show DEST)
magick "$TEMP_ROLLED" "$TEMP_BASE" "$TEMP_MASK" -composite "$TEMP_RESULT"


echo "Tile created: $TEMP_RESULT"

echo "Generating tiled wallpaper (1920x1080)..."
# Create a 1920x1080 canvas filled with the seamless tile
magick -size 1920x1080 tile:"$TEMP_RESULT" "$OUTPUT_IMG"

echo "Cleaning up..."
rm "$TEMP_BASE" "$TEMP_ROLLED" "$TEMP_MASK" "$TEMP_RESULT"

echo "Done! Wallpaper saved to $OUTPUT_IMG"
