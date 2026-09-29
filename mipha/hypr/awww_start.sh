#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
state_file="$state_dir/current_wallpaper.path"
source "$HOME/.config/hypr/awww_collection.sh"
load_wallpaper_config
fallback_wallpaper="$HOME/.config/hypr/wallpaper.jpg"

mkdir -p "$state_dir"

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

wallpaper="$(pick_wallpaper "$wallpaper")" || wallpaper="$fallback_wallpaper"

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
  wallpaper="$fallback_wallpaper"
fi

printf '%s\n' "$wallpaper" > "$state_file"
"$HOME/.config/hypr/awww_set_wallpaper.sh" "$wallpaper"
