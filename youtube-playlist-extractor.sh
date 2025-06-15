#!/bin/bash

# Check if a URL is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <playlist-url>"
    exit 1
fi

# Get the playlist URL from the argument
PLAYLIST_URL="$1"

# Check if the URL contains the substring "playlist?"
if [[ "$PLAYLIST_URL" != *"playlist?"* ]]; then
    echo "Error: The provided URL does not seem to be a valid playlist URL."
    exit 1
fi

# Use yt-dlp to extract video URLs from the playlist
echo '[skye] Retrieving playlist video identifiers...' >&2
VIDEO_URLS=$(yt-dlp --cookies-from-browser safari --get-id "$PLAYLIST_URL" | sed "s|^|https://www.youtube.com/watch?v=|")

# Check if yt-dlp succeeded
if [ $? -ne 0 ]; then
    echo "Failed to extract video URLs. Please check your playlist URL."
    exit 1
fi

# Print the video URLs
echo "$VIDEO_URLS"
