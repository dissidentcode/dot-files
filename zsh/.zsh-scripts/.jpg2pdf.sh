#!/bin/bash

# directory containing JPGs
input_dir="$1"

if [[ -z "$input_dir" ]]; then
  echo "Please specify an input directory."
  exit 1
fi

# for each JPG in the input directory (non-recursive)
find "$input_dir" -maxdepth 1 -type f -iname "*.jpg" -print0 | while IFS= read -r -d '' jpg; do
  # Convert the JPG to PDF
  # The output PDF will have the same base name as the JPG file
  convert "$jpg" "${jpg%.*}.pdf"
done
