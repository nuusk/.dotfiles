#!/usr/bin/env bash
set -euo pipefail
config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
hypr_dir="$config_root/hypr"
theme="$config_root/green-static/toggle-theme.sh"

choice=$(printf '%s\n' \
  'apps        launch application' \
  'run         execute command' \
  'workspace   switch window / workspace' \
  'worktree    open project worktree' \
  'accent      cycle green / amber / violet / cyan / sepia / warcraft' \
  'warcraft    parchment / bronze / blue / game drawings' \
  'parchment   sepia / original sketch collection' \
  'light       full light desktop' \
  'dark        full dark desktop' \
  'wallpaper   select collection' \
  'capture     select region' \
  'window      capture window' \
  | wofi --dmenu --prompt 'console >' --no-custom-entry --cache-file /dev/null) || exit 0

case "${choice%% *}" in
  apps) exec wofi --show drun --prompt 'apps >' ;;
  run) exec wofi --show run --prompt 'run >' ;;
  workspace) exec "$hypr_dir/workspace-overview.sh" ;;
  worktree) exec "$hypr_dir/open-worktree.sh" ;;
  accent) exec "$theme" accent cycle ;;
  warcraft|parchment) exec "$theme" preset "${choice%% *}" ;;
  light|dark) exec "$theme" set "${choice%% *}" ;;
  capture) exec "$HOME/.local/bin/screenshot" ;;
  window) exec "$hypr_dir/window-screenshot.sh" ;;
  wallpaper)
    root="$HOME/code/backgrounds/cycling"
    [[ -d "$root" ]] || exit 0
    collection=$(find "$root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
      | grep -E '^[a-zA-Z0-9_-]+$' | grep -v '^paused-wallpapers$' | sort \
      | wofi --dmenu --prompt 'wallpaper >' --no-custom-entry --cache-file /dev/null) || exit 0
    [[ "$collection" =~ ^[a-zA-Z0-9_-]+$ && -d "$root/$collection" ]] || exit 0
    # Preserve the configured interval and comments.
    sed -i "s/^collection=.*/collection=$collection/" "$hypr_dir/wallpaper.conf"
    exec "$hypr_dir/awww_cycle_once.sh" next
    ;;
esac
