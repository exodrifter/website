#!/bin/bash
set -e

video_id=$1
json=$2

# Parse the title of the video for streaming service and air date
name=($(echo $json | jq -r ".name"))
service=${name[0]}
date=${name[2]}
time=${name[3]}

# Get the title of the stream from the description
description=$(echo $json | jq -r ".description")
description=${description//|/&#124;}

# Name for the post and thumbnail that can be written to the filesystem
file_name="$date-${time//:/-}"

# Download the thumbnail
if [ "$3" != "--skip-thumb" ]; then
  echo "Downloading thumbnail..."
  base_link=$(echo $json | jq -r ".pictures.base_link")
  thumb_path="../assets/thumbs/$file_name.jpg"
  curl -sH "Authorization: bearer $access_token" "$base_link.jpg" --output "$thumb_path"
fi

# Update the post if it does exist
post_path="../_posts/$file_name.md"
if [ -f "$post_path" ]; then
  echo "Updating post at \"$post_path\"..."
  sed -i "s/title: .*/title: \"$description\"/" $post_path
  sed -i "s/date: .*/date: ${date}T$time/" $post_path
  sed -i "s/  teaser: .*/  teaser: \\/assets\\/thumbs\\/$file_name.jpg/" $post_path
  # TODO: Add service tag if it doesn't exist?

# Create the post if it doesn't exist
else
  echo "Creating post at \"$post_path\"..."
  cat > $post_path <<EOL
---
title: "$description"
date: ${date}T${time}
header:
  teaser: /assets/thumbs/$file_name.jpg
categories: []
tags:
- $service
---
{% include video id="$video_id" provider="vimeo" %}
EOL
fi

echo "Done."
