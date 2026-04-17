#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
state_file="$state_dir/current_wallpaper.path"
fallback_wallpaper="$HOME/.config/hypr/wallpaper.jpg"
wallpaper="${1:-}"

mkdir -p "$state_dir"

if [ -z "$wallpaper" ] && [ -f "$state_file" ]; then
  wallpaper=$(<"$state_file")
fi

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
  wallpaper="$fallback_wallpaper"
fi

printf '%s\n' "$wallpaper" > "$state_file"

outputs="$(hyprctl -j monitors 2>/dev/null | jq -r '.[].name' | paste -sd, -)"

if [ -n "$outputs" ]; then
  awww img "$wallpaper" \
    --outputs "$outputs" \
    --transition-type none \
    --resize crop \
    --filter Lanczos3
else
  awww img "$wallpaper" \
    --transition-type none \
    --resize crop \
    --filter Lanczos3
fi
