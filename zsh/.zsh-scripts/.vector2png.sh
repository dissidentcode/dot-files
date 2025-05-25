#!/bin/bash

# directory containing vector images (SVG, AI, and EPS)
input_dir="$1"

if [[ -z "$input_dir" ]]; then
  echo "Please specify an input directory."
  exit 1
fi

# for each SVG, AI, and EPS file in the input directory (non-recursive)
find "$input_dir" -maxdepth 1 -type f \( -iname "*.svg" -o -iname "*.ai" -o -iname "*.eps" \) -print0 | while IFS= read -r -d '' img; do
  # Convert the vector image to PNG
  # The output PNG will have the same base name as the vector file
  convert "$img" "${img%.*}.png" 2>/dev/null
done
