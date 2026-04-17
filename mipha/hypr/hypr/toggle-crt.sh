#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
state_file="$state_dir/crt_shader.path"
shader="$HOME/.config/hypr/shaders/crt_funny.frag"

mkdir -p "$state_dir"

current="$(hyprctl getoption decoration:screen_shader -j | jq -r '.str // ""')"

if [ -f "$state_file" ] || [ "$current" = "$shader" ]; then
  rm -f "$state_file"
  hyprctl keyword decoration:screen_shader "" >/dev/null 2>&1
  notify-send "CRT shader off" "Screen shader disabled"
  exit 0
fi

printf '%s\n' "$shader" > "$state_file"
hyprctl keyword decoration:screen_shader "$shader" >/dev/null 2>&1
notify-send "CRT shader on" "Funny CRT shader enabled"
