#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
state_file="$state_dir/current_wallpaper.path"
fallback_wallpaper="$HOME/.config/hypr/wallpaper.jpg"
wallpaper="${1:-}"
if [ -n "${AWWW_TRANSITION_TYPE:-}" ]; then
  transition_type="$AWWW_TRANSITION_TYPE"
else
  transition_types=(wipe wave wipe wave fade)
  transition_type="${transition_types[$((RANDOM % ${#transition_types[@]}))]}"
fi
transition_duration="${AWWW_TRANSITION_DURATION:-0.55}"
transition_fps="${AWWW_TRANSITION_FPS:-120}"
transition_step="${AWWW_TRANSITION_STEP:-210}"
transition_angle="${AWWW_TRANSITION_ANGLE:-$((RANDOM % 360))}"
transition_wave="${AWWW_TRANSITION_WAVE:-$((8 + RANDOM % 10)),$((4 + RANDOM % 6))}"
transition_bezier="${AWWW_TRANSITION_BEZIER:-0.92,0.00,0.10,1.00}"

mkdir -p "$state_dir"

if [ -z "$wallpaper" ]; then
  source "$HOME/.config/hypr/awww_collection.sh"
  load_wallpaper_config
  if [ -f "$state_file" ]; then
    wallpaper=$(<"$state_file")
  fi
  wallpaper="$(pick_wallpaper "$wallpaper")" || wallpaper="$fallback_wallpaper"
fi

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
  wallpaper="$fallback_wallpaper"
fi

resize=crop
layout=default
fill_color=000000
collection_display="$(dirname -- "$wallpaper")/display.conf"
if [[ -r "$collection_display" ]]; then source "$collection_display"; fi
case "$resize" in crop|fit|no|stretch) ;; *) resize=crop ;; esac
[[ "$fill_color" =~ ^[[:xdigit:]]{6}([[:xdigit:]]{2})?$ ]] || fill_color=000000

printf '%s\n' "$wallpaper" > "$state_file"

transition_args=(
  --transition-type "$transition_type"
  --transition-duration "$transition_duration"
  --transition-fps "$transition_fps"
  --transition-step "$transition_step"
  --transition-angle "$transition_angle"
  --transition-wave "$transition_wave"
  --transition-bezier "$transition_bezier"
)
monitors="$(hyprctl -j monitors)"
if [[ "$layout" == corner ]]; then
  renderer="$(dirname -- "${BASH_SOURCE[0]}")/awww_render_corner.sh"
  while IFS=$'\t' read -r output width height transform; do
    # Rotated monitors need their physical canvas dimensions exchanged.
    if (( transform % 2 )); then swap="$width"; width="$height"; height="$swap"; fi
    canvas=$("$renderer" "$wallpaper" "$width" "$height" "${fill_color:0:6}")
    awww img "$canvas" --outputs "$output" "${transition_args[@]}" --resize no
  done < <(jq -r '.[] | [.name, .width, .height, (.transform // 0)] | @tsv' <<< "$monitors")
else
  outputs=$(jq -r '.[].name' <<< "$monitors" | paste -sd, -)
  output_args=()
  [[ -n "$outputs" ]] && output_args=(--outputs "$outputs")
  awww img "$wallpaper" "${output_args[@]}" "${transition_args[@]}" \
    --resize "$resize" --fill-color "$fill_color" --filter Lanczos3
fi
