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
  "$HOME/.config/hypr/shaders/cyber_glitch.frag"
)

sleep_times=(0.05 0.06 0.08 0.10 0.12 0.14)

pick_random_shader() {
  local index=$((RANDOM % ${#shaders[@]}))
  printf '%s\n' "${shaders[$index]}"
}

pick_random_sleep() {
  local index=$((RANDOM % ${#sleep_times[@]}))
  printf '%s\n' "${sleep_times[$index]}"
}

while [ -f "$enabled_file" ]; do
  [ -f "$enabled_file" ] || exit 0
  hyprctl keyword decoration:screen_shader "$(pick_random_shader)" >/dev/null 2>&1 || true
  sleep "$(pick_random_sleep)"
done
