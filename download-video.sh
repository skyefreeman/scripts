#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <video-url> <destination-directory>"
    exit 1
fi

VIDEO_URL="$1"
DESTINATION_DIR="$2"
DESTINATION_DIR_PATH=$(dirname "$DESTINATION_DIR")

# make the directories if they don't exist
mkdir -p "$DESTINATION_DIR_PATH"

echo "[skye] Retrieving video name..." >&2
VIDEO_TITLE_RAW=$(yt-dlp --get-title --cookies-from-browser safari "$VIDEO_URL")

# Get the video title and sanitize it for use as a filename
echo "[skye] Received: $VIDEO_TITLE_RAW" >&2
VIDEO_TITLE=$(echo "$VIDEO_TITLE_RAW" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_')
UNIQUE_FILENAME="${VIDEO_TITLE}.mp4"
echo "[skye] Doctored filename: $VIDEO_TITLE" >&2

echo "[skye] Will begin downloading: $VIDEO_URL to $DESTINATION_DIR ..." >&2
yt-dlp --cookies-from-browser safari -f "bestvideo+bestaudio" -t mp4 -o "$DESTINATION_DIR/$UNIQUE_FILENAME" "$VIDEO_URL"
echo "[skye] Downloaded video as: $UNIQUE_FILENAME" >&2
