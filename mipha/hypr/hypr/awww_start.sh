#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
state_file="$state_dir/current_wallpaper.path"
collection_dir="$HOME/code/backgrounds/cycling/ff7"
fallback_wallpaper="$HOME/.config/hypr/wallpaper.jpg"

mkdir -p "$state_dir"

collect_first_wallpaper() {
  find "$collection_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort | head -n1
}

pkill hyprpaper >/dev/null 2>&1 || true

if ! awww query >/dev/null 2>&1; then
  pkill -x awww-daemon >/dev/null 2>&1 || true
  nohup awww-daemon --no-cache >/tmp/awww-daemon.log 2>&1 &
fi

for _ in {1..30}; do
  if awww query >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done

wallpaper=""
if [ -f "$state_file" ]; then
  wallpaper=$(<"$state_file")
fi

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
  wallpaper="$(collect_first_wallpaper)"
fi

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
  wallpaper="$fallback_wallpaper"
fi

printf '%s\n' "$wallpaper" > "$state_file"
"$HOME/.config/hypr/awww_set_wallpaper.sh" "$wallpaper"
