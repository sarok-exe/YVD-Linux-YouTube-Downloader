#!/bin/bash

# YouTube Video Downloader - Simple & Working Version
# Fixed by AI Assistant

# --- Basic Config ---
OUTPUT_DIR="downloads"
URL_FILE="videos.txt"
LOG_FILE="download.log"
MAX_TITLE_LENGTH=120

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# --- Initial Checks ---
[ ! -f "$URL_FILE" ] && echo -e "${RED}Error: Create videos.txt file first!${NC}" && exit 1
command -v yt-dlp >/dev/null || { echo -e "${RED}Error: Install yt-dlp first!${NC}"; exit 1; }

# --- Prepare ---
mkdir -p "$OUTPUT_DIR"
> "$LOG_FILE"
TOTAL=$(grep -vc '^#' "$URL_FILE")
COUNT=0

echo -e "${GREEN}YouTube Downloader Started${NC}"
echo -e "Found ${BLUE}$TOTAL${NC} videos to download"

# --- Download Function ---
download() {
    local url="$1"
    local id=$(echo "$url" | sed 's/.*[?&]v=\([^&]*\).*/\1/')
    local title=$(yt-dlp --get-title "$url" 2>/dev/null | head -1 | tr -cd '[:print:]' | cut -c1-$MAX_TITLE_LENGTH)
    
    [ -z "$title" ] && title="video_$id"
    
    echo -e "\n${YELLOW}Downloading ($((++COUNT))/$TOTAL): ${BLUE}$title${NC}"
    
    yt-dlp -f 'best[height<=1080]' \
        -o "$OUTPUT_DIR/%(title)s.%(ext)s" \
        --no-warnings \
        "$url" 2>&1 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}✓ Success: $title${NC}"
    else
        echo -e "${RED}✗ Failed: $title${NC}"
    fi
}

# --- Main Process ---
while read -r url; do
    [[ "$url" =~ ^#|^$ ]] && continue
    download "$url"
done < "$URL_FILE"

echo -e "\n${GREEN}Finished!${NC}"
echo -e "Check ${BLUE}$LOG_FILE${NC} for details"