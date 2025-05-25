#!/bin/bash

# directory containing PDFs
input_dir="$1"

if [[ -z "$input_dir" ]]; then
  echo "Please specify an input directory."
  exit 1
fi

# for each PDF in the input directory (non-recursive)
find "$input_dir" -maxdepth 1 -type f -iname "*.pdf" -print0 | while IFS= read -r -d '' pdf; do
  # Convert the PDF to JPG
  # The output JPG will have the same base name as the PDF file
  convert -density 300 "$pdf" "${pdf%.*}.jpg"
done
