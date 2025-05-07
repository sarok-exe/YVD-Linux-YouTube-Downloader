#!/bin/bash

# YVD for Linux Project
# Copyright (C) 2025 by سارﯣۥڪ あ
# This project is free and open-source software.
# Feel free to use, modify, and distribute it.
# Follow for More : https://t.me/Sarok_exe

# --- Configuration ---
OUTPUT_DIR="youtube_downloads"
PARALLEL_JOBS=2 # Number of simultaneous downloads
URL_FILE="videos.txt"
LOG_FILE="download.log"
# Quality Selection: Prefers separate video/audio up to 1080p, merges them (requires ffmpeg).
QUALITY_FORMAT="bestvideo[height<=?1080]+bestaudio/best[height<=?1080]/bestvideo+bestaudio/best"
MERGE_FORMAT="mp4" # mp4, mkv, etc. (requires ffmpeg for merging)
FILENAME_TITLE_LENGTH=100 # Limit title length in filename to prevent "File name too long" errors

# Base yt-dlp arguments (add more if needed)
YT_DLP_ARGS="--newline --progress --retries 5 --fragment-retries 5 --merge-output-format $MERGE_FORMAT --restrict-filenames"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Setup & Dependencies ---
set -e # Exit on error
set -o pipefail # Exit on pipe failure

command -v yt-dlp >/dev/null || { echo -e "${RED}❌ Error: yt-dlp is not installed.${NC}"; exit 1; }
command -v xargs >/dev/null || { echo -e "${RED}❌ Error: xargs is not installed.${NC}"; exit 1; }
command -v grep >/dev/null || { echo -e "${RED}❌ Error: grep is not installed.${NC}"; exit 1; }
command -v stdbuf >/dev/null || { echo -e "${RED}❌ Error: stdbuf is not installed.${NC}"; exit 1; }
command -v tr >/dev/null || { echo -e "${RED}❌ Error: tr is not installed.${NC}"; exit 1; }
command -v sed >/dev/null || { echo -e "${RED}❌ Error: sed is not installed.${NC}"; exit 1; }

if [[ "$QUALITY_FORMAT" == *"+"* ]]; then
    command -v ffmpeg >/dev/null || {
      echo -e "${YELLOW}⚠️ Warning: ffmpeg not found. Merging best video/audio might fail.${NC}"
      echo -e "${YELLOW}  Install ffmpeg for best quality results (e.g., 'sudo apt install ffmpeg').${NC}"
    }
fi

mkdir -p "$OUTPUT_DIR"
[ ! -f "$URL_FILE" ] && { echo -e "${RED}❌ Error: URL file '$URL_FILE' not found.${NC}"; exit 1; }
truncate -s 0 "$LOG_FILE" # Clear log

# --- Signal Handling ---
cleanup() {
    echo -e "\n${RED}🚨 Interrupt received. Stopping downloads...${NC}"
    pkill -P $$ yt-dlp 2>/dev/null || true # Kill yt-dlp children of this script
    pkill -P $$ bash 2>/dev/null || true # Kill bash subshells created by xargs
    echo -e "${YELLOW}🛑 Aborted by user. Check '$LOG_FILE'.${NC}"
    exit 1
}
trap cleanup SIGINT SIGTERM SIGQUIT

# --- Header ---
echo -e "${CYAN}🎥 YVD Downloader${NC}"
echo -e "Parallel jobs: ${BLUE}${PARALLEL_JOBS}${NC}"
echo -e "URL list     : ${BLUE}${URL_FILE}${NC}"
echo -e "Output dir   : ${BLUE}${OUTPUT_DIR}${NC}"
echo -e "Quality      : ${BLUE}${QUALITY_FORMAT}${NC}"
echo -e "Filename limit: Title <= ${BLUE}${FILENAME_TITLE_LENGTH}${NC} chars"
echo -e "Log file     : ${BLUE}${LOG_FILE}${NC}"
echo -e "----------------------------------"

# --- Download Function ---
download_video() {
    local url="$1"
    local url_short_hash=$(echo -n "$url" | md5sum | cut -c1-6)
    local log_prefix="[${url_short_hash}]"
    local title
    # Attempt to get title, fall back if error
    title=$(yt-dlp --get-title --no-warnings "$url" 2>/dev/null | tr -cd '[:print:]\t' | cut -c1-60) || title="[Title Error - $url_short_hash]"
    local display_prefix
    printf -v display_prefix "%-65s" "${YELLOW}[${title}]${NC}" # Pad title part for display

    echo "$(date '+%Y-%m-%d %H:%M:%S') $log_prefix ($title) Starting download for URL: $url" >> "$LOG_FILE"

    # Output template: Limit the title part of the filename
    local output_template="$OUTPUT_DIR/%(title).${FILENAME_TITLE_LENGTH}s [%(id)s].%(ext)s"

    # Execute yt-dlp and process its progress output
    # stdbuf: Ensure output is line-buffered
    # tr: Convert carriage returns to newlines for grep
    # grep: Filter for download progress lines
    # while read: Process each progress line
    if stdbuf -oL yt-dlp \
        -f "$QUALITY_FORMAT" \
        $YT_DLP_ARGS \
        -o "$output_template" \
        "$url" \
        2>> "$LOG_FILE" | \
        stdbuf -oL tr '\r' '\n' | \
        stdbuf -oL grep --line-buffered '\[download\]' | \
        while IFS= read -r line; do
            local progress_info=$(echo "$line" | sed -e 's/.*\[download\]\s*//' -e 's/\s*$//')
            printf "\r\033[K%s | %s" "$display_prefix" "$progress_info"
        done; then
        # Check yt-dlp exit status explicitly via PIPESTATUS
        if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
             printf "\r\033[K%s | ${GREEN}✔ Done${NC}\n" "$display_prefix"
             echo "$(date '+%Y-%m-%d %H:%M:%S') $log_prefix ($title) ✔ Finished successfully." >> "$LOG_FILE"
             return 0 # Success
        else
             # Exit code from yt-dlp was non-zero (yt-dlp failed)
             printf "\r\033[K%s | ${RED}❌ Failed (yt-dlp error ${PIPESTATUS[0]}, check log)${NC}\n" "$display_prefix"
             echo "$(date '+%Y-%m-%d %H:%M:%S') $log_prefix ($title) ❌ Failed with yt-dlp exit code ${PIPESTATUS[0]}. See stderr above in log." >> "$LOG_FILE"
             return 1 # Explicit failure from yt-dlp
        fi
    else
        # Pipeline failed before yt-dlp finished, or yt-dlp failed very early
        local exit_code=${PIPESTATUS[0]:-$?} # Get yt-dlp status if available, else pipeline status
        printf "\r\033[K%s | ${RED}❌ Failed (Pipeline error $exit_code, check log)${NC}\n" "$display_prefix"
        echo "$(date '+%Y-%m-%d %H:%M:%S') $log_prefix ($title) ❌ Failed (Pipeline exit code $exit_code). See stderr above in log." >> "$LOG_FILE"
        return 1 # Failure
    fi
}

# Export the function and necessary variables for xargs subshells
export -f download_video
export OUTPUT_DIR LOG_FILE YT_DLP_ARGS QUALITY_FORMAT FILENAME_TITLE_LENGTH # Export vars
export RED GREEN YELLOW BLUE CYAN NC # Export colors

# --- Process URLs ---
# Count non-empty, non-comment lines in the URL file
TOTAL_URLS=$(grep -vE '^\s*(#|$)' "$URL_FILE" | wc -l)
echo -e "Processing ${BLUE}${TOTAL_URLS}${NC} URLs..."
echo -e "----------------------------------"

# Read URLs, skip comments/empty lines, process in parallel using xargs
grep -vE '^\s*(#|$)' "$URL_FILE" | \
    xargs -P "$PARALLEL_JOBS" -I {} bash -c 'download_video "$@"' _ {}

XARGS_EXIT_CODE=$? # Capture xargs exit code

# --- Final Report ---
echo -e "----------------------------------"
echo -e "${CYAN}📊 Summary${NC}"

# Count success/failure entries in the log file
SUCCESS_COUNT=$(grep -c '✔ Finished successfully.' "$LOG_FILE")
FAILED_COUNT=$(grep -c '❌ Failed' "$LOG_FILE")

echo -e "${GREEN}✔ Succeeded: ${SUCCESS_COUNT}${NC}"
if [[ $FAILED_COUNT -gt 0 ]]; then
    echo -e "${RED}✘ Failed   : ${FAILED_COUNT}${NC}"
else
    # If no failures logged by download_video function
    if [[ $XARGS_EXIT_CODE -eq 0 ]]; then
       echo -e "${GREEN}✨ All attempted downloads finished successfully!${NC}"
    else
       # xargs itself reported a non-zero exit code, but no explicit download failures were logged
       echo -e "${YELLOW}⚠️ All downloads logged success, but xargs reported an issue (Code: $XARGS_EXIT_CODE). Check log for details.${NC}"
    fi
fi
echo -e "Full log: ${BLUE}${LOG_FILE}${NC}"
echo -e "----------------------------------"

# Determine final exit code for the script based on logged failures or xargs exit code
if [[ $FAILED_COUNT -gt 0 ]] || [[ $XARGS_EXIT_CODE -ne 0 ]]; then
    exit 1 # Exit with error status if any download failed or xargs had an issue
else
    exit 0 # Exit with success status if all downloads logged success and xargs was okay
fi

# Removed detailed xargs exit code explanations to simplify
