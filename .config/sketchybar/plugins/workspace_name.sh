#!/usr/bin/env bash

if [[ -n "$AEROSPACE_FOCUSED_WORKSPACE" ]]; then
  sketchybar --set space_display label="$AEROSPACE_FOCUSED_WORKSPACE"
else
  sketchybar --set space_display label="?"
fi
