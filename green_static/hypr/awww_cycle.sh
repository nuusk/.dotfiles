#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
lock_file="$state_dir/awww_cycle.lock"
source "$HOME/.config/hypr/awww_collection.sh"
setter="$HOME/.config/hypr/awww_set_wallpaper.sh"
cycle_once="$HOME/.config/hypr/awww_cycle_once.sh"

mkdir -p "$state_dir"
exec 9>"$lock_file"
flock -n 9 || exit 0

active_collection=""
last_change=$SECONDS
while true; do
  if load_wallpaper_config; then
    if [[ "$collection" != "$active_collection" ]]; then
      if "$setter"; then
        active_collection="$collection"
        last_change=$SECONDS
      fi
    elif (( SECONDS - last_change >= interval )); then
      "$cycle_once" next || true
      last_change=$SECONDS
    fi
  fi
  sleep 2
done
