#!/bin/bash

# directory containing HEIC images
input_dir="$1"

# jpg image quality
quality="$2"

if [[ -z "$input_dir" ]]; then
  echo "Please specify an input directory."
  exit 1
elif [[ -z "$quality" ]]; then
  echo "Please specify image quality (e.g., 80 for 80%)."
  exit 1
fi

# for each HEIC file in the input directory (non-recursive)
find "$input_dir" -maxdepth 1 -type f -iname "*.heic" -print0 | while IFS= read -r -d '' img; do
  # Convert the HEIC image to JPG
  # The output JPG will have the same base name as the HEIC file
  convert "$img" -quality "$quality%" "${img%.*}.jpg"
done
