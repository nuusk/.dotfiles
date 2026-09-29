#!/usr/bin/env bash

load_wallpaper_config() {
  collection=earthbound
  interval=1800
  source "$HOME/.config/hypr/wallpaper.conf" || return 1
  [[ "$collection" =~ ^[a-zA-Z0-9_-]+$ ]] || return 1
  [[ "$interval" =~ ^[1-9][0-9]*$ ]] || return 1
  collection_dir="$HOME/code/backgrounds/cycling/$collection"
  [[ -d "$collection_dir" ]]
}

list_wallpapers() {
  find "$collection_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) | sort
}

pick_wallpaper() {
  local current="$1" direction="${2:-current}" step=0 i next_index
  local -a wallpapers
  mapfile -t wallpapers < <(list_wallpapers)
  ((${#wallpapers[@]})) || return 1
  case "$direction" in
    next) step=1 ;;
    prev) step=-1 ;;
  esac
  for i in "${!wallpapers[@]}"; do
    if [[ "${wallpapers[$i]}" == "$current" ]]; then
      next_index=$(( (i + step + ${#wallpapers[@]}) % ${#wallpapers[@]} ))
      printf '%s\n' "${wallpapers[$next_index]}"
      return 0
    fi
  done
  if [[ "$direction" == prev ]]; then
    printf '%s\n' "${wallpapers[${#wallpapers[@]}-1]}"
  else
    printf '%s\n' "${wallpapers[0]}"
  fi
}
