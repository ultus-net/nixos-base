#!/usr/bin/env bash

# Check for ImageMagick
if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick (magick) is not installed."
    exit 1
fi

LOGO="wallpapers/nixos-logo.png"
RESIZED_LOGO="temp_logo_resized.png"
TILE_IMG="temp_hex_tile.png"

# Logo Size
LOGO_SIZE=80

# Grid Configuration (Dense packing)
GRID_WIDTH=90
GRID_HEIGHT=156
HALF_W=$((GRID_WIDTH / 2))
HALF_H=$((GRID_HEIGHT / 2))

echo "Resizing logo..."
magick "$LOGO" -resize "${LOGO_SIZE}x${LOGO_SIZE}" "$RESIZED_LOGO"

# Function to generate wallpaper
generate_variant() {
    local NAME=$1
    local BG_COLOR=$2
    local C1=$3 # Darker tone
    local C2=$4 # Lighter tone
    local OUTPUT="wallpapers/nixos-hex-grid-${NAME}.png"
    local COLORED_LOGO="temp_logo_${NAME}.png"
    
    echo "Generating variant: $NAME (BG: $BG_COLOR, Colors: $C1 -> $C2)..."

    # 0. Recolor the logo (Two-Tone Gradient Map)
    # We convert to grayscale, then map the grayscale values to a gradient between C1 and C2.
    # We protect the Alpha channel so transparency is preserved.
    # Note: +level-colors color_black,color_white
    magick "$RESIZED_LOGO" \
        -colorspace gray \
        -channel RGB +level-colors "$C1","$C2" +channel \
        "$COLORED_LOGO"

    # 1. Create canvas with one logo in the center
    magick -size "${GRID_WIDTH}x${GRID_HEIGHT}" xc:"$BG_COLOR" \
        "$COLORED_LOGO" -gravity center -composite \
        "$TILE_IMG"

    # 2. Roll it (shift it so the center object moves to corners)
    magick "$TILE_IMG" -roll "+${HALF_W}+${HALF_H}" "$TILE_IMG"

    # 3. Draw the second logo in the new center
    magick "$TILE_IMG" \
        "$COLORED_LOGO" -gravity center -composite \
        "$TILE_IMG"

    # 4. Tile it
    magick -size 1920x1080 tile:"$TILE_IMG" "$OUTPUT"

    # Cleanup temp logo
    rm "$COLORED_LOGO"
}

# Define Variants
# Format: "name" "bg_hex" "dark_tone" "light_tone"

# 1. Nord Dark (Original) - Frost Blues
generate_variant "nord-dark" "#2e3440" "#5E81AC" "#88C0D0"

# 2. Nord Light (Snow Storm) - Dark Grays
generate_variant "nord-light" "#eceff4" "#2e3440" "#4c566a"

# 3. Nord Frost (Blueish) - Lighter Frost/Whites
generate_variant "nord-frost" "#5e81ac" "#88C0D0" "#eceff4"

# 4. Nord Red (Aurora) - White/Silver
generate_variant "nord-red" "#bf616a" "#d8dee9" "#eceff4"

# 5. Dracula (Background) - Purple/Pink
generate_variant "dracula" "#282a36" "#6272a4" "#bd93f9"

# 6. Solarized Dark - Blue/Cyan
generate_variant "solarized-dark" "#002b36" "#268bd2" "#2aa198"

# 7. Gruvbox Dark - Orange/Yellow
generate_variant "gruvbox-dark" "#282828" "#d65d0e" "#fabd2f"

echo "Cleaning up..."
rm "$RESIZED_LOGO" "$TILE_IMG"

echo "Done! Generated 7 variants in wallpapers/."
