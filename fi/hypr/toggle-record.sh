#!/usr/bin/env bash
set -euo pipefail

state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
state_file="$state_dir/wf-recorder.path"
log_file="$state_dir/wf-recorder.log"
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

output_name="$(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .name' | head -n1)"

if [ -z "$output_name" ] || [ "$output_name" = "null" ]; then
  notify-send "Recording failed" "Could not determine focused monitor"
  exit 1
fi

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
output="$output_dir/recording_${timestamp}.mkv"
printf '%s\n' "$output" > "$state_file"

wf-recorder -o "$output_name" -f "$output" >"$log_file" 2>&1 &
sleep 0.25

if pgrep -x wf-recorder >/dev/null 2>&1; then
  notify-send "Recording started" "$output"
else
  rm -f "$state_file"
  error_msg="$(sed -n '1,3p' "$log_file" 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g')"
  [ -z "$error_msg" ] && error_msg="wf-recorder failed to start"
  notify-send "Recording failed" "$error_msg"
  exit 1
fi
