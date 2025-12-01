#!/bin/bash

# CoachGuru Production Build Script
# This script builds a release APK and copies it to Desktop

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  CoachGuru Production Build Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo -e "${YELLOW}[1/6] Extracting version from pubspec.yaml...${NC}"
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
BUILD_NUMBER=$(grep "^version:" pubspec.yaml | sed 's/.*+//')
echo -e "${GREEN}✓ Version: ${VERSION} (Build: ${BUILD_NUMBER})${NC}"
echo ""

echo -e "${YELLOW}[2/6] Cleaning Flutter project...${NC}"
flutter clean
echo -e "${GREEN}✓ Clean completed${NC}"
echo ""

echo -e "${YELLOW}[3/6] Getting Flutter dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

echo -e "${YELLOW}[4/6] Building release APK...${NC}"
flutter build apk --release
echo -e "${GREEN}✓ APK build completed${NC}"
echo ""

echo -e "${YELLOW}[5/6] Preparing output directory...${NC}"
DESKTOP_DIR="$HOME/Desktop/CoachGuru"
mkdir -p "$DESKTOP_DIR"
echo -e "${GREEN}✓ Output directory ready: $DESKTOP_DIR${NC}"
echo ""

echo -e "${YELLOW}[6/6] Copying APK to Desktop...${NC}"
APK_SOURCE="$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
APK_DEST="$DESKTOP_DIR/CoachGuru.apk"

if [ -f "$APK_SOURCE" ]; then
    cp "$APK_SOURCE" "$APK_DEST"
    echo -e "${GREEN}✓ APK copied successfully${NC}"
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}  BUILD SUCCESSFUL!${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "APK Location: ${GREEN}$APK_DEST${NC}"
    echo -e "APK Size: ${GREEN}$(du -h "$APK_DEST" | cut -f1)${NC}"
    echo ""
    echo -e "${BLUE}Ready for distribution!${NC}"
else
    echo -e "${RED}✗ ERROR: APK file not found at $APK_SOURCE${NC}"
    exit 1
fi

