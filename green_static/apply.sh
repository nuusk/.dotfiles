#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC_HOME="/home/nuus"

copy_text() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  sed -i "s|$SRC_HOME|$HOME|g" "$dst"
}

copy_exec() {
  local src="$1"
  local dst="$2"
  copy_text "$src" "$dst"
  chmod +x "$dst"
}

copy_raw() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

copy_tree() {
  local src_dir="$1"
  local dst_dir="$2"
  mkdir -p "$dst_dir"
  cp -r "$src_dir"/. "$dst_dir"/
}

echo "Applying green_static from: $ROOT"

copy_text "$ROOT/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
copy_text "$ROOT/hypr/hypridle.conf" "$HOME/.config/hypr/hypridle.conf"
copy_text "$ROOT/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
copy_exec "$ROOT/hypr/glitch-launch.sh" "$HOME/.config/hypr/glitch-launch.sh"
copy_exec "$ROOT/hypr/toggle-record.sh" "$HOME/.config/hypr/toggle-record.sh"
copy_exec "$ROOT/hypr/awww_start.sh" "$HOME/.config/hypr/awww_start.sh"
copy_exec "$ROOT/hypr/awww_cycle_once.sh" "$HOME/.config/hypr/awww_cycle_once.sh"
copy_exec "$ROOT/hypr/awww_cycle.sh" "$HOME/.config/hypr/awww_cycle.sh"
copy_exec "$ROOT/hypr/awww_monitor_listener.sh" "$HOME/.config/hypr/awww_monitor_listener.sh"
copy_exec "$ROOT/hypr/awww_set_wallpaper.sh" "$HOME/.config/hypr/awww_set_wallpaper.sh"
copy_exec "$ROOT/hypr/crt_cycle.sh" "$HOME/.config/hypr/crt_cycle.sh"
copy_exec "$ROOT/hypr/toggle-crt.sh" "$HOME/.config/hypr/toggle-crt.sh"
copy_tree "$ROOT/hypr/shaders" "$HOME/.config/hypr/shaders"
copy_raw "$ROOT/hypr/wallpaper.jpg" "$HOME/.config/hypr/wallpaper.jpg"
copy_tree "$ROOT/wallpapers/ff7" "$HOME/code/backgrounds/cycling/ff7"

copy_text "$ROOT/waybar/config" "$HOME/.config/waybar/config"
copy_text "$ROOT/waybar/style.css" "$HOME/.config/waybar/style.css"
copy_exec "$ROOT/waybar/special_workspace.sh" "$HOME/.config/waybar/special_workspace.sh"
copy_exec "$ROOT/waybar/recording_status.sh" "$HOME/.config/waybar/recording_status.sh"
copy_exec "$ROOT/waybar/mic_status.sh" "$HOME/.config/waybar/mic_status.sh"

copy_text "$ROOT/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
copy_text "$ROOT/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
copy_text "$ROOT/wofi/config" "$HOME/.config/wofi/config"
copy_text "$ROOT/wofi/style.css" "$HOME/.config/wofi/style.css"
copy_text "$ROOT/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"

copy_text "$ROOT/nvim/lua/plugins/theme.lua" "$HOME/.config/nvim/lua/plugins/theme.lua"

copy_text "$ROOT/dolphin/dolphinrc" "$HOME/.config/dolphinrc"
copy_text "$ROOT/dolphin/green_static.qss" "$HOME/.config/dolphin-green_static.qss"
copy_exec "$ROOT/dolphin/dolphin-wrapper.sh" "$HOME/.local/bin/dolphin"

copy_text "$ROOT/kde/kdeglobals" "$HOME/.config/kdeglobals"
copy_raw "$ROOT/kde/color-schemes/GreenStatic.colors" "$HOME/.local/share/color-schemes/GreenStatic.colors"

copy_exec "$ROOT/helpers/dunst_toggle.sh" "$HOME/.local/bin/dunst_toggle"
copy_exec "$ROOT/helpers/screenshot.sh" "$HOME/.local/bin/screenshot"

if [ -f "$HOME/.mozilla/firefox/profiles.ini" ]; then
  while IFS= read -r profile_path; do
    [ -z "$profile_path" ] && continue
    case "$profile_path" in
      /*) target="$profile_path" ;;
      *) target="$HOME/.mozilla/firefox/$profile_path" ;;
    esac
    mkdir -p "$target/chrome"
    copy_text "$ROOT/firefox/userChrome.css" "$target/chrome/userChrome.css"
    copy_text "$ROOT/firefox/userContent.css" "$target/chrome/userContent.css"
    copy_text "$ROOT/firefox/user.js" "$target/user.js"
  done < <(awk -F= '/^Path=/{print $2}' "$HOME/.mozilla/firefox/profiles.ini")
fi

echo "green_static files copied."
echo "Recommended follow-up: hyprctl reload && pkill waybar; waybar >/dev/null 2>&1 & && dunstctl reload ~/.config/dunst/dunstrc"
