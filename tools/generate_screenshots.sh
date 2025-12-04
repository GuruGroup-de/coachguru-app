#!/bin/bash

# generate_screenshots.sh - Bulk generate optimized screenshots
# Usage: ./generate_screenshots.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SOURCE_DIR="screenshots"
TARGET_DIR="docs/screenshots"

echo -e "${GREEN}=== Generating Optimized Screenshots ===${NC}"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}Error: ImageMagick not found. Please install it:${NC}"
    echo "  macOS: brew install imagemagick"
    echo "  Ubuntu: sudo apt-get install imagemagick"
    exit 1
fi

# Create target directory
mkdir -p "$TARGET_DIR"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${YELLOW}Warning: Source directory '$SOURCE_DIR' not found${NC}"
    echo "Creating empty directory. Please add screenshots to $SOURCE_DIR/"
    exit 0
fi

# Delete old screenshots
echo -e "${GREEN}Cleaning old screenshots...${NC}"
rm -f "$TARGET_DIR"/*.png "$TARGET_DIR"/*.jpg "$TARGET_DIR"/*.jpeg 2>/dev/null || true

# Process PNG files
echo -e "${GREEN}Processing PNG files...${NC}"
PNG_COUNT=0
for img in "$SOURCE_DIR"/*.png "$SOURCE_DIR"/*.PNG; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        echo "  Optimizing: $filename"
        convert "$img" -strip -resize 1080x1920\> -quality 90 "$TARGET_DIR/$filename"
        PNG_COUNT=$((PNG_COUNT + 1))
    fi
done

# Process JPG files (convert to PNG)
echo -e "${GREEN}Processing JPG files...${NC}"
JPG_COUNT=0
for img in "$SOURCE_DIR"/*.jpg "$SOURCE_DIR"/*.JPG "$SOURCE_DIR"/*.jpeg "$SOURCE_DIR"/*.JPEG; do
    if [ -f "$img" ]; then
        filename=$(basename "$img" | sed 's/\.[jJ][pP][eE]?[gG]$//').png
        echo "  Converting and optimizing: $filename"
        convert "$img" -strip -resize 1080x1920\> -quality 90 "$TARGET_DIR/$filename"
        JPG_COUNT=$((JPG_COUNT + 1))
    fi
done

TOTAL=$((PNG_COUNT + JPG_COUNT))

if [ $TOTAL -eq 0 ]; then
    echo -e "${YELLOW}No images found in $SOURCE_DIR${NC}"
    echo "Please add .png or .jpg files to $SOURCE_DIR/"
else
    echo -e "${GREEN}✅ Processed $TOTAL images:${NC}"
    echo "  - PNG: $PNG_COUNT"
    echo "  - JPG: $JPG_COUNT"
    echo "  - Output: $TARGET_DIR/"
    
    # Show file sizes
    echo ""
    echo "File sizes:"
    ls -lh "$TARGET_DIR"/*.png 2>/dev/null | awk '{print "  " $9 ": " $5}' || true
fi

echo -e "${GREEN}=== Complete ===${NC}"

