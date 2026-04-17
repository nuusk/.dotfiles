#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
lock_file="$state_dir/awww_cycle.lock"
state_file="$state_dir/current_wallpaper.path"
collection_dir="$HOME/code/backgrounds/cycling/ff7"
setter="$HOME/.config/hypr/awww_set_wallpaper.sh"
interval=1800

mkdir -p "$state_dir"
exec 9>"$lock_file"
flock -n 9 || exit 0

list_wallpapers() {
  find "$collection_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort
}

pick_next() {
  local current="$1"
  mapfile -t wallpapers < <(list_wallpapers)

  if [ "${#wallpapers[@]}" -eq 0 ]; then
    return 1
  fi

  if [ -z "$current" ]; then
    printf '%s\n' "${wallpapers[0]}"
    return 0
  fi

  for i in "${!wallpapers[@]}"; do
    if [ "${wallpapers[$i]}" = "$current" ]; then
      next_index=$(( (i + 1) % ${#wallpapers[@]} ))
      printf '%s\n' "${wallpapers[$next_index]}"
      return 0
    fi
  done

  printf '%s\n' "${wallpapers[0]}"
}

while true; do
  sleep "$interval"
  current=""
  if [ -f "$state_file" ]; then
    current=$(<"$state_file")
  fi

  next="$(pick_next "$current")" || continue
  "$setter" "$next" >/dev/null 2>&1 || true
done
