#!/bin/bash

IMAGE1="1.jpg"
IMAGE2="2.jpg"
IMAGE3="3.jpg"
IMAGE4="4.jpg"
TIMING_XML="lakeside.xml"
PROPS_XML="lakeside-wallpaper.xml"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE1_SRC="$SCRIPT_DIR/$IMAGE1"
IMAGE2_SRC="$SCRIPT_DIR/$IMAGE2"
IMAGE3_SRC="$SCRIPT_DIR/$IMAGE3"
IMAGE4_SRC="$SCRIPT_DIR/$IMAGE4"
TIMING_XML_SRC="$SCRIPT_DIR/$TIMING_XML"
PROPS_XML_SRC="$SCRIPT_DIR/$PROPS_XML"

# Check if running as root
if [[ "$EUID" -eq 0 ]]; then
    XML_DEST="/usr/share/gnome-background-properties"
    IMG_DEST="/usr/share/backgrounds/lakeside"
else
    XML_DEST="$HOME/.local/share/gnome-background-properties"
    IMG_DEST="$HOME/.local/share/backgrounds/lakeside"
fi

BACKGROUND_DIR="${IMG_DEST%/lakeside}"

# Check for -r / --remove flag
if [[ "$1" == "-r" || "$1" == "--remove" ]]; then
    rm -rf "$IMG_DEST"
    rm -f "$XML_DEST/$PROPS_XML"
    echo "Lakeside wallpaper removed successfully."
    exit 0
fi

# Create destinations if they don't exist
mkdir -p "$XML_DEST"
mkdir -p "$IMG_DEST"

# Check for existing files (conflicts)
CONFLICT=false
[[ -f "$IMG_DEST/$IMAGE1"     ]] && CONFLICT=true
[[ -f "$IMG_DEST/$IMAGE2"     ]] && CONFLICT=true
[[ -f "$IMG_DEST/$IMAGE3"     ]] && CONFLICT=true
[[ -f "$IMG_DEST/$IMAGE4"     ]] && CONFLICT=true
[[ -f "$IMG_DEST/$TIMING_XML" ]] && CONFLICT=true
[[ -f "$XML_DEST/$PROPS_XML"  ]] && CONFLICT=true

if [[ "$CONFLICT" == true ]]; then
    echo "One or more files already exist at the destination:"
    [[ -f "$IMG_DEST/$IMAGE1"     ]] && echo "  $IMG_DEST/$IMAGE1"
    [[ -f "$IMG_DEST/$IMAGE2"     ]] && echo "  $IMG_DEST/$IMAGE2"
    [[ -f "$IMG_DEST/$IMAGE3"     ]] && echo "  $IMG_DEST/$IMAGE3"
    [[ -f "$IMG_DEST/$IMAGE4"     ]] && echo "  $IMG_DEST/$IMAGE4"
    [[ -f "$IMG_DEST/$TIMING_XML" ]] && echo "  $IMG_DEST/$TIMING_XML"
    [[ -f "$XML_DEST/$PROPS_XML"  ]] && echo "  $XML_DEST/$PROPS_XML"
    echo ""
    read -rp "Override existing files? [y/N]: " REPLY
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Copy images and timing XML into the backgrounds folder
cp "$IMAGE1_SRC"     "$IMG_DEST/$IMAGE1"
cp "$IMAGE2_SRC"     "$IMG_DEST/$IMAGE2"
cp "$IMAGE3_SRC"     "$IMG_DEST/$IMAGE3"
cp "$IMAGE4_SRC"     "$IMG_DEST/$IMAGE4"
cp "$TIMING_XML_SRC" "$IMG_DEST/$TIMING_XML"

# Replace @BACKGROUNDDIR@ in timing XML with the actual path
sed -i "s|@BACKGROUNDDIR@|${BACKGROUND_DIR}|g" "$IMG_DEST/$TIMING_XML"

# Copy properties XML and substitute its placeholder
cp "$PROPS_XML_SRC" "$XML_DEST/$PROPS_XML"
sed -i "s|@BACKGROUNDDIR@|${BACKGROUND_DIR}|g" "$XML_DEST/$PROPS_XML"

# Verify the placeholder was actually replaced — abort if not
if grep -q '@BACKGROUNDDIR@' "$XML_DEST/$PROPS_XML"; then
    echo "ERROR: Placeholder substitution failed in $XML_DEST/$PROPS_XML"
    echo "Removing installed files to prevent Settings crash..."
    rm -rf "$IMG_DEST"
    rm -f "$XML_DEST/$PROPS_XML"
    exit 1
fi

echo "Lakeside wallpaper installed successfully."
echo "  Images + timing XML -> $IMG_DEST"
echo "  Properties XML      -> $XML_DEST/$PROPS_XML"
echo ""
echo "Installed properties XML content:"
cat "$XML_DEST/$PROPS_XML"
