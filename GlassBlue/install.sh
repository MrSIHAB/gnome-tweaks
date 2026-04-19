#!/bin/bash

LIGHT_IMAGE="GlassBlueLight.png"
DARK_IMAGE="GlassBlueDark.jpg"
XML_FILE="GlassBlue.xml"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIGHT_SRC="$SCRIPT_DIR/$LIGHT_IMAGE"
DARK_SRC="$SCRIPT_DIR/$DARK_IMAGE"
XML_SRC="$SCRIPT_DIR/$XML_FILE"

# Check if running as root
if [[ "$EUID" -eq 0 ]]; then
    XML_DEST="/usr/share/gnome-background-properties"
    IMG_DEST="/usr/share/backgrounds/GlassBlue"
else
    XML_DEST="$HOME/.local/share/gnome-background-properties"
    IMG_DEST="$HOME/.local/share/backgrounds/GlassBlue"
fi

# The parent backgrounds dir (without /GlassBlue) is what the XML placeholder expects
BACKGROUND_DIR="${IMG_DEST%/GlassBlue}"

# Check for -r / --remove flag
if [[ "$1" == "-r" || "$1" == "--remove" ]]; then
    rm -f "$IMG_DEST/$LIGHT_IMAGE"
    rm -f "$IMG_DEST/$DARK_IMAGE"
    rm -f "$XML_DEST/$XML_FILE"
    echo "GlassBlue wallpaper removed successfully."
    exit 0
fi

# Create XML destination directory if it doesn't exist
mkdir -p "$XML_DEST"

# Check for existing files (conflicts)
CONFLICT=false
[[ -f "$IMG_DEST/$LIGHT_IMAGE" ]] && CONFLICT=true
[[ -f "$IMG_DEST/$DARK_IMAGE"  ]] && CONFLICT=true
[[ -f "$XML_DEST/$XML_FILE"    ]] && CONFLICT=true

if [[ "$CONFLICT" == true ]]; then
    echo "One or more files already exist at the destination:"
    [[ -f "$IMG_DEST/$LIGHT_IMAGE" ]] && echo "  $IMG_DEST/$LIGHT_IMAGE"
    [[ -f "$IMG_DEST/$DARK_IMAGE"  ]] && echo "  $IMG_DEST/$DARK_IMAGE"
    [[ -f "$XML_DEST/$XML_FILE"    ]] && echo "  $XML_DEST/$XML_FILE"
    echo ""
    read -rp "Override existing files? [y/N]: " REPLY
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Create image destination directory and copy files
mkdir -p "$IMG_DEST"
cp "$LIGHT_SRC" "$IMG_DEST/$LIGHT_IMAGE"
cp "$DARK_SRC"  "$IMG_DEST/$DARK_IMAGE"
cp "$XML_SRC"   "$XML_DEST/$XML_FILE"

# Replace @BACKGROUNDDIR@ placeholder in the copied XML with the actual path
sed -i "s|@BACKGROUNDDIR@|${BACKGROUND_DIR}|g" "$XML_DEST/$XML_FILE"

echo "GlassBlue wallpaper installed successfully."
echo "  Images -> $IMG_DEST"
echo "  XML    -> $XML_DEST/$XML_FILE"
