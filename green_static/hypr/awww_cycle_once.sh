#!/usr/bin/env bash
set -euo pipefail

direction="${1:-next}"
state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
state_file="$state_dir/current_wallpaper.path"
source "$HOME/.config/hypr/awww_collection.sh"
load_wallpaper_config
setter="$HOME/.config/hypr/awww_set_wallpaper.sh"

mkdir -p "$state_dir"

current=""
if [ -f "$state_file" ]; then
  current=$(<"$state_file")
fi

next="$(pick_wallpaper "$current" "$direction")" || {
  exit 1
}

"$setter" "$next" >/dev/null 2>&1
