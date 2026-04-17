#!/bin/bash

shader="/home/nuus/.config/hypr/shaders/cyber_glitch.frag"

if [ "$1" = "--shader" ] && [ -n "$2" ]; then
  shader="$2"
  shift 2
fi

"$@" &

if [ -f "$shader" ]; then
  (
    # Let the new window map first, then pulse the full-screen shader briefly.
    previous_shader="$(hyprctl getoption decoration:screen_shader -j | jq -r '.str // ""')"
    sleep 0.04
    hyprctl keyword decoration:screen_shader "$shader" >/dev/null 2>&1
    sleep 0.16
    hyprctl keyword decoration:screen_shader "$previous_shader" >/dev/null 2>&1
  ) &
fi
