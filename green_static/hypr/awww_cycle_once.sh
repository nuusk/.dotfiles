#!/usr/bin/env bash
set -euo pipefail

direction="${1:-next}"
state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
state_file="$state_dir/current_wallpaper.path"
collection_dir="$HOME/code/backgrounds/cycling/ff7"
setter="$HOME/.config/hypr/awww_set_wallpaper.sh"

mkdir -p "$state_dir"

list_wallpapers() {
  find "$collection_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort
}

pick_wallpaper() {
  local current="$1"
  local direction="$2"
  local step next_index
  mapfile -t wallpapers < <(list_wallpapers)

  if [ "${#wallpapers[@]}" -eq 0 ]; then
    return 1
  fi

  if [ -z "$current" ]; then
    if [ "$direction" = "prev" ]; then
      printf '%s\n' "${wallpapers[$((${#wallpapers[@]} - 1))]}"
    else
      printf '%s\n' "${wallpapers[0]}"
    fi
    return 0
  fi

  step=1
  [ "$direction" = "prev" ] && step=-1

  for i in "${!wallpapers[@]}"; do
    if [ "${wallpapers[$i]}" = "$current" ]; then
      next_index=$(( (i + step + ${#wallpapers[@]}) % ${#wallpapers[@]} ))
      printf '%s\n' "${wallpapers[$next_index]}"
      return 0
    fi
  done

  printf '%s\n' "${wallpapers[0]}"
}

current=""
if [ -f "$state_file" ]; then
  current=$(<"$state_file")
fi

next="$(pick_wallpaper "$current" "$direction")" || {
  exit 1
}

"$setter" "$next" >/dev/null 2>&1
