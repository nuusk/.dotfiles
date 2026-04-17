#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
state_file="$state_dir/wf-recorder.path"
mkdir -p "$state_dir"

if pgrep -x wf-recorder >/dev/null 2>&1; then
  pkill -INT -x wf-recorder

  output=""
  if [ -f "$state_file" ]; then
    output=$(<"$state_file")
    rm -f "$state_file"
  fi

  if [ -n "$output" ]; then
    notify-send "Recording saved" "$output"
  else
    notify-send "Recording stopped" "wf-recorder stopped"
  fi

  exit 0
fi

output_dir="$HOME/Videos/Recordings"
mkdir -p "$output_dir"

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output="$output_dir/recording_${timestamp}.mp4"
printf '%s\n' "$output" > "$state_file"

notify-send "Recording started" "$output"

wf-recorder -f "$output" >/dev/null 2>&1 &
