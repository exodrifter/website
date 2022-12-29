#!/bin/bash
set -e
cd "$(dirname "$0")"

if [ ! -f "../env.sh" ]; then
  echo "env.sh is not defined, see README.md"
  exit 1
fi
source ../env.sh

# Parse arguments
if [ $# -eq 0 ] || [ -z $1 ]; then
  echo "posts.sh <video id>\n"
  echo "flags:"
  echo "  --skip-thumb   Skip the step to download thumbnails."
  exit 1
fi
video_id=$1

# Fetch the video's metadata
echo "Downloading metadata..."
json=$(curl -sH "Authorization: bearer $access_token" "https://api.vimeo.com/videos/$video_id?fields=name,description,pictures.base_link")
./shared/post.sh "$json" $2