#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
enabled_file="$state_dir/crt_enabled"
shader_lock="$state_dir/screen_shader.lock"
cycle_script="$HOME/.config/hypr/crt_cycle.sh"

mkdir -p "$state_dir"

clear_shader() {
  (
    exec 9>"$shader_lock"
    flock 9
    hyprctl keyword decoration:screen_shader "" >/dev/null 2>&1 || true
  )
}

if [ -f "$enabled_file" ]; then
  rm -f "$enabled_file"
  pkill -TERM -f "$cycle_script" >/dev/null 2>&1 || true
  clear_shader
  exit 0
fi

touch "$enabled_file"
nohup "$cycle_script" >/dev/null 2>&1 &
