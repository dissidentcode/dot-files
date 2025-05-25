#!/bin/bash

input_dir="$1"

if [[ -z "$input_dir" ]]; then
  echo "Please specify an input directory."
  exit 1
fi

input_dir=$(realpath "$input_dir")

find "$input_dir" \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.svg" -o -iname "*.gif" -o -iname "*.tiff" -o -iname "*.bmp" -o -iname "*.jp2" -o -iname "*.eps" -o -iname "*.heif" \) -exec bash -c '
  for img; do
    mime_type=$(file --mime-type -b "$img")
    ext=${mime_type#image/}
    ext=${ext/jp2/j2k} # Convert jp2 to j2k for JPEG 2000 files
    output_dir="$0/$ext"
    mkdir -p "$output_dir"
    mv "$img" "$output_dir"
  done
' "$input_dir" {} +
