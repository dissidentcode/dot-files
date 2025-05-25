#!/bin/sh
# Fast preview script for lf/fzf with binary detection and fallback previews

# Cache tool availability
HAS_HIGHLIGHT=$(command -v highlight)
HAS_TREE=$(command -v tree)
HAS_MEDIAINFO=$(command -v mediainfo)
HAS_GLOW=$(command -v glow)
HAS_PDFTOTEXT=$(command -v pdftotext)
HAS_ZIPINFO=$(command -v zipinfo)
HAS_UNAR=$(command -v unar)
HAS_7Z=$(command -v 7z)
HAS_PISTOL=$(command -v pistol)
HAS_BAT=$(command -v bat)
HAS_FILE=$(command -v file)

MAX_LINES=30

# Helper: Truncate output
limit_output() {
  head -n "$MAX_LINES"
}

# Helper: Detect if a file is binary
is_binary() {
  [ -f "$1" ] && ! grep -qI . "$1"
}

# Preview logic based on file extension
case "$1" in
*.png | *.jpg | *.jpeg | *.mkv | *.mp4 | *.m4v)
  [ -n "$HAS_MEDIAINFO" ] && "$HAS_MEDIAINFO" "$1" | limit_output || echo "Media file: $1"
  ;;

*.md)
  [ -n "$HAS_GLOW" ] && "$HAS_GLOW" -s dark "$1" | limit_output
  ;;

*.[pP][dD][fF])
  [ -n "$HAS_PDFTOTEXT" ] && "$HAS_PDFTOTEXT" "$1" - | limit_output || echo "PDF: $1"
  ;;

*.zip)
  [ -n "$HAS_ZIPINFO" ] && "$HAS_ZIPINFO" "$1" | limit_output || echo "ZIP archive: $1"
  ;;

*.tar.gz) tar -ztvf "$1" | limit_output ;;
*.tar.bz2) tar -jtvf "$1" | limit_output ;;
*.tar) tar -tvf "$1" | limit_output ;;

*.rar)
  if [ -n "$HAS_UNAR" ]; then
    "$HAS_UNAR" -l "$1" | limit_output
  elif [ -n "$HAS_7Z" ]; then
    "$HAS_7Z" l "$1" | limit_output
  else
    echo "No tool to preview .rar file"
  fi
  ;;

*.7z)
  [ -n "$HAS_7Z" ] && "$HAS_7Z" l "$1" | limit_output || echo "7z archive: $1"
  ;;

*.zsh* | *.bash* | *.git*)
  [ -n "$HAS_PISTOL" ] && "$HAS_PISTOL" "$1" | limit_output
  ;;

*)
  if [ -f "$1" ]; then
    if is_binary "$1"; then
      if [ -n "$HAS_MEDIAINFO" ]; then
        "$HAS_MEDIAINFO" "$1" | limit_output
      elif [ -n "$HAS_FILE" ]; then
        "$HAS_FILE" "$1"
      else
        echo "Binary file — no preview"
      fi
    else
      if [ -n "$HAS_HIGHLIGHT" ]; then
        "$HAS_HIGHLIGHT" "$1" -O ansi --force | limit_output
      elif [ -n "$HAS_BAT" ]; then
        "$HAS_BAT" --style=plain --color=always "$1" | limit_output
      else
        cat "$1" | limit_output
      fi
    fi
  elif [ -d "$1" ]; then
    [ -n "$HAS_TREE" ] && "$HAS_TREE" "$1" -La 1 | limit_output || echo "Directory: $1"
  else
    echo "No preview available"
  fi
  ;;
esac
