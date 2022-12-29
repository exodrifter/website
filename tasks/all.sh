#!/bin/bash
set -e
cd "$(dirname "$0")"

if [ ! -f "../env.sh" ]; then
  echo "env.sh is not defined, see README.md"
  exit 1
fi
source ../env.sh

# Parse arguments
if [ $# -ne 0 ]; then
  echo "all.sh doesn't take any arguments"
  exit 1
fi

# Fetch the user's metadata
echo "Downloading user's metadata..."
json=$(curl -sH "Authorization: bearer $access_token" "https://api.vimeo.com/users/104901742/videos?fields=uri,name,description,pictures.base_link,parent_folder.name")

# Create or update the post for each result
echo $json | jq -c '.data[] | select(.parent_folder.name == "Streams")' | while read video; do
  video_id=$(echo $video | jq -r '.uri')
  video_id=${video_id##*/}
  echo "Found video $video_id"
  ./shared/post.sh "$video_id" "$video"
done

# TODO: Follow pagination
