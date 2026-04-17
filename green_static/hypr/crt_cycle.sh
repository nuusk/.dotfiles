#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
enabled_file="$state_dir/crt_enabled"
lock_file="$state_dir/crt_cycle.lock"

mkdir -p "$state_dir"
exec 9>"$lock_file"
flock -n 9 || exit 0

shaders=(
  "$HOME/.config/hypr/shaders/crt_funny_1.frag"
  "$HOME/.config/hypr/shaders/crt_funny_2.frag"
  "$HOME/.config/hypr/shaders/crt_funny_3.frag"
  "$HOME/.config/hypr/shaders/crt_funny_4.frag"
)

sleep_times=(0.10 0.08 0.11 0.07)

while [ -f "$enabled_file" ]; do
  for i in "${!shaders[@]}"; do
    [ -f "$enabled_file" ] || exit 0
    hyprctl keyword decoration:screen_shader "${shaders[$i]}" >/dev/null 2>&1 || true
    sleep "${sleep_times[$i]}"
  done
done
