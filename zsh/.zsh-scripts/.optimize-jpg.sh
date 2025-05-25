#!/bin/bash

# directory containing images
input_dir="$1"

# target image quality
quality="$2"

if [[ -z "$input_dir" ]]; then
  echo "Please specify an input directory."
  exit 1
elif [[ -z "$quality" ]]; then
  echo "Please specify image quality."
  exit 1
fi

# for each jpg or jpeg in the input directory (non-recursive)
find "$input_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0 | while IFS= read -r -d '' img; do
  cp "$img" "${img%.*}-optimized.jpg"
  jpegoptim -m "$quality" "${img%.*}-optimized.jpg"
done