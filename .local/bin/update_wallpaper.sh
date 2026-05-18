#!/usr/bin/env bash

# Build an array of image file paths
mapfile -d '' files < <(find -L "$HOME/.config/wallpapers" -maxdepth 1 -type f -print0 | sort -z)

# Ensure there are images to choose from
if [ ${#files[@]} -eq 0 ]; then
  echo "No images found in $HOME/.config/wallpapers"
  exit 1
fi

# Calculate the index using day-of-year modulo the number of files (0-indexed)
index=$(( $(date +%j) % ${#files[@]} ))
selected="${files[$index]}"

# Wait for awww-daemon to be ready before setting the image
while ! awww query >/dev/null 2>&1; do sleep 0.1; done

# Set the wallpaper
awww img "$selected"

# Update tmp wallpaper
# cp "$selected" "/tmp/wp.webp"
