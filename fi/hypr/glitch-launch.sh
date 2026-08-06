#!/bin/bash

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
state_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
shader_lock="$state_dir/screen_shader.lock"
crt_enabled_file="$state_dir/crt_enabled"
shader="$config_dir/shaders/cyber_glitch.frag"

if [ "$1" = "--shader" ] && [ -n "$2" ]; then
  shader="$2"
  shift 2
fi

if [ "$#" -eq 0 ]; then
  exit 64
fi

"$@" &

if [ -f "$shader" ]; then
  mkdir -p "$state_dir" || exit 0
  exec 9>"$shader_lock" || exit 0

  if flock -n 9; then
    # Let the new window map first, then pulse the full-screen shader briefly.
    previous_shader="$(hyprctl getoption decoration:screen_shader -j 2>/dev/null | jq -r '.str // ""' 2>/dev/null)"

    # If an older launch pulse got stuck, do not preserve it as the baseline.
    if [ ! -f "$crt_enabled_file" ]; then
      case "$previous_shader" in
        "$config_dir/shaders/cyber_glitch.frag"|"$config_dir/shaders/wofi_glitch.frag")
          previous_shader=""
          ;;
      esac
    fi

    restore_shader() {
      hyprctl keyword decoration:screen_shader "$previous_shader" >/dev/null 2>&1 || true
    }

    trap restore_shader EXIT
    trap 'restore_shader; exit 0' HUP INT TERM

    sleep 0.04
    hyprctl keyword decoration:screen_shader "$shader" >/dev/null 2>&1 || exit 0
    sleep 0.16
  fi
fi
