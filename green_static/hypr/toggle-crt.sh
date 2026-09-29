#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
enabled_file="$state_dir/crt_enabled"
cycle_script="$HOME/.config/hypr/crt_cycle.sh"

mkdir -p "$state_dir"

if [ -f "$enabled_file" ]; then
  rm -f "$enabled_file"
  pkill -TERM -f "$cycle_script" >/dev/null 2>&1 || true
  hyprctl keyword decoration:screen_shader "" >/dev/null 2>&1
  exit 0
fi

touch "$enabled_file"
nohup "$cycle_script" >/dev/null 2>&1 &
