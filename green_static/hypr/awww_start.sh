#!/usr/bin/env bash
set -euo pipefail

wallpaper="/home/nuus/.config/hypr/wallpaper.jpg"

pkill hyprpaper >/dev/null 2>&1 || true

if ! awww query >/dev/null 2>&1; then
  pkill -x awww-daemon >/dev/null 2>&1 || true
  nohup awww-daemon --no-cache >/tmp/awww-daemon.log 2>&1 &
fi

for _ in {1..30}; do
  if awww query >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done

awww img "$wallpaper" \
  --transition-type none \
  --resize crop \
  --filter Lanczos3
