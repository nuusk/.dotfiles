#!/usr/bin/env bash
set -euo pipefail

wallpaper="${1:-/home/nuus/.config/hypr/wallpaper.jpg}"

awww img "$wallpaper" \
  --transition-type none \
  --resize crop \
  --filter Lanczos3
