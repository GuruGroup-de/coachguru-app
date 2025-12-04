#!/bin/bash

# upload_apk.sh - Upload APK to GitHub Release
# Usage: ./upload_apk.sh <TAG> <GITHUB_TOKEN>
# Example: ./upload_apk.sh v2.0.0 ghp_xxxxxxxxxxxx

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo "Usage: $0 <TAG> <GITHUB_TOKEN>"
    echo "Example: $0 v2.0.0 ghp_xxxxxxxxxxxx"
    exit 1
fi

TAG=$1
GITHUB_TOKEN=$2
REPO="GuruGroup-de/coachguru-app"
ASSET_NAME="coachguru-latest.apk"
APK_DIR="build/app/outputs/flutter-apk"

# Validate TAG format
if [[ ! $TAG =~ ^v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    echo -e "${YELLOW}Warning: Tag format should be vX.Y.Z (e.g., v2.0.0)${NC}"
fi

# Find the newest APK file
if [ ! -d "$APK_DIR" ]; then
    echo -e "${RED}Error: APK directory not found: $APK_DIR${NC}"
    exit 1
fi

APK_FILE=$(find "$APK_DIR" -name "app-release.apk" -type f | head -n 1)

if [ -z "$APK_FILE" ] || [ ! -f "$APK_FILE" ]; then
    echo -e "${RED}Error: No APK file found in $APK_DIR${NC}"
    echo "Please build the APK first: flutter build apk --release"
    exit 1
fi

echo -e "${GREEN}Found APK: $APK_FILE${NC}"
APK_SIZE=$(du -h "$APK_FILE" | cut -f1)
echo "APK Size: $APK_SIZE"

# Extract version from TAG (remove 'v' prefix)
VERSION=${TAG#v}
RELEASE_NAME="CoachGuru $TAG"

echo ""
echo -e "${GREEN}=== Uploading APK to GitHub Release ===${NC}"
echo "Repository: $REPO"
echo "Tag: $TAG"
echo "Version: $VERSION"
echo "Release Name: $RELEASE_NAME"
echo "Asset Name: $ASSET_NAME"
echo ""

# Check if release exists
echo "Checking if release $TAG exists..."
RELEASE_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO/releases/tags/$TAG")

HTTP_CODE=$(echo "$RELEASE_RESPONSE" | tail -n1)
RELEASE_BODY=$(echo "$RELEASE_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${YELLOW}Release $TAG already exists${NC}"
    RELEASE_ID=$(echo "$RELEASE_BODY" | jq -r '.id')
    
    # Check for existing asset with same name
    echo "Checking for existing assets..."
    ASSETS_RESPONSE=$(curl -s \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO/releases/$RELEASE_ID/assets")
    
    ASSET_IDS=$(echo "$ASSETS_RESPONSE" | jq -r ".[] | select(.name == \"$ASSET_NAME\") | .id")
    
    if [ -n "$ASSET_IDS" ]; then
        echo -e "${YELLOW}Found existing asset: $ASSET_NAME${NC}"
        for ASSET_ID in $ASSET_IDS; do
            echo "Deleting asset ID: $ASSET_ID"
            DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" \
                -X DELETE \
                -H "Authorization: token $GITHUB_TOKEN" \
                -H "Accept: application/vnd.github.v3+json" \
                "https://api.github.com/repos/$REPO/releases/assets/$ASSET_ID")
            
            DELETE_CODE=$(echo "$DELETE_RESPONSE" | tail -n1)
            if [ "$DELETE_CODE" = "204" ]; then
                echo -e "${GREEN}Asset deleted successfully${NC}"
            else
                echo -e "${RED}Failed to delete asset. HTTP Code: $DELETE_CODE${NC}"
            fi
        done
    fi
    
    # Update release name
    echo "Updating release name to: $RELEASE_NAME"
    UPDATE_RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X PATCH \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$RELEASE_NAME\"}" \
        "https://api.github.com/repos/$REPO/releases/$RELEASE_ID")
    
    UPDATE_CODE=$(echo "$UPDATE_RESPONSE" | tail -n1)
    if [ "$UPDATE_CODE" = "200" ]; then
        echo -e "${GREEN}Release updated successfully${NC}"
    else
        echo -e "${YELLOW}Warning: Failed to update release name. HTTP Code: $UPDATE_CODE${NC}"
    fi
    
else
    echo -e "${GREEN}Release $TAG does not exist, creating new release...${NC}"
    
    # Create new release
    CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -d "{
            \"tag_name\": \"$TAG\",
            \"name\": \"$RELEASE_NAME\",
            \"body\": \"Automated release of CoachGuru $TAG\\n\\n## Build Information\\n- Version: $VERSION\\n- Asset: $ASSET_NAME\",
            \"draft\": false,
            \"prerelease\": false
        }" \
        "https://api.github.com/repos/$REPO/releases")
    
    CREATE_CODE=$(echo "$CREATE_RESPONSE" | tail -n1)
    CREATE_BODY=$(echo "$CREATE_RESPONSE" | sed '$d')
    
    if [ "$CREATE_CODE" = "201" ]; then
        RELEASE_ID=$(echo "$CREATE_BODY" | jq -r '.id')
        echo -e "${GREEN}Release created successfully (ID: $RELEASE_ID)${NC}"
    else
        echo -e "${RED}Failed to create release. HTTP Code: $CREATE_CODE${NC}"
        echo "Response: $CREATE_BODY"
        exit 1
    fi
fi

# Upload APK
echo ""
echo -e "${GREEN}Uploading APK: $APK_FILE${NC}"
echo "Asset name: $ASSET_NAME"
echo "Release ID: $RELEASE_ID"

UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Content-Type: application/vnd.android.package-archive" \
    --data-binary "@$APK_FILE" \
    "https://uploads.github.com/repos/$REPO/releases/$RELEASE_ID/assets?name=$ASSET_NAME")

UPLOAD_CODE=$(echo "$UPLOAD_RESPONSE" | tail -n1)
UPLOAD_BODY=$(echo "$UPLOAD_RESPONSE" | sed '$d')

if [ "$UPLOAD_CODE" = "201" ]; then
    echo -e "${GREEN}✅ APK uploaded successfully!${NC}"
    ASSET_URL=$(echo "$UPLOAD_BODY" | jq -r '.browser_download_url')
    echo ""
    echo "Release URL: https://github.com/$REPO/releases/tag/$TAG"
    echo "Download URL: $ASSET_URL"
else
    echo -e "${RED}❌ Failed to upload APK. HTTP Code: $UPLOAD_CODE${NC}"
    echo "Response: $UPLOAD_BODY"
    exit 1
fi

echo ""
echo -e "${GREEN}=== Upload Complete ===${NC}"

