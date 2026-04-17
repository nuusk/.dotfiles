#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
state_file="$state_dir/current_wallpaper.path"
fallback_wallpaper="$HOME/.config/hypr/wallpaper.jpg"
wallpaper="${1:-}"
transition_type="${AWWW_TRANSITION_TYPE:-random}"
transition_duration="${AWWW_TRANSITION_DURATION:-0.8}"
transition_fps="${AWWW_TRANSITION_FPS:-90}"
transition_step="${AWWW_TRANSITION_STEP:-170}"
transition_angle="${AWWW_TRANSITION_ANGLE:-$((RANDOM % 360))}"
transition_wave="${AWWW_TRANSITION_WAVE:-$((12 + RANDOM % 18)),$((6 + RANDOM % 12))}"
transition_bezier="${AWWW_TRANSITION_BEZIER:-0.85,0.00,0.15,1.00}"

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
    --transition-type "$transition_type" \
    --transition-duration "$transition_duration" \
    --transition-fps "$transition_fps" \
    --transition-step "$transition_step" \
    --transition-angle "$transition_angle" \
    --transition-wave "$transition_wave" \
    --transition-bezier "$transition_bezier" \
    --resize crop \
    --filter Lanczos3
else
  awww img "$wallpaper" \
    --transition-type "$transition_type" \
    --transition-duration "$transition_duration" \
    --transition-fps "$transition_fps" \
    --transition-step "$transition_step" \
    --transition-angle "$transition_angle" \
    --transition-wave "$transition_wave" \
    --transition-bezier "$transition_bezier" \
    --resize crop \
    --filter Lanczos3
fi
