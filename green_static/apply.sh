#!/usr/bin/env bash
set -euo pipefail

bundle_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
target_home="$HOME"
with_extras=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-home)
      [[ $# -ge 2 && $2 == /* ]] || { echo '--target-home requires an absolute path' >&2; exit 2; }
      target_home="$2"
      shift 2
      ;;
    --with-extras) with_extras=1; shift ;;
    --help)
      echo 'Usage: ./apply.sh [--target-home /absolute/path] [--with-extras]'
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

backup_root="$target_home/.local/state/green-static/backups/$(date +%Y%m%d-%H%M%S)-$$"

copy_file() {
  local source="$1" target="$2"
  if [[ -e "$target" || -L "$target" ]]; then
    local backup="$backup_root/${target#"$target_home/"}"
    mkdir -p "$(dirname "$backup")"
    cp -a -- "$target" "$backup"
  fi
  mkdir -p "$(dirname "$target")"
  # Replace symlinks rather than writing through them into another checkout.
  local temporary
  temporary=$(mktemp "${target}.XXXXXX")
  cp -p -- "$source" "$temporary"
  mv -f -- "$temporary" "$target"
}

copy_tree() {
  local source="$1" target="$2" file
  while IFS= read -r -d '' file; do
    # Hyprland watches its config. Install entrypoints only after all their
    # dependencies exist, so an automatic reload cannot see a partial install.
    case "$file" in
      "$bundle_root/hypr/hyprland.lua"|"$bundle_root/hypr/hyprland.conf") continue ;;
    esac
    copy_file "$file" "$target/${file#"$source/"}"
  done < <(find "$source" -type f -print0)
}

for component in hypr waybar kitty dunst wofi gtk-3.0 gtk-4.0 satty nvim green-static; do
  copy_tree "$bundle_root/$component" "$target_home/.config/$component"
done
copy_tree "$bundle_root/wallpapers" "$target_home/code/backgrounds/cycling"
copy_file "$bundle_root/dolphin/dolphinrc" "$target_home/.config/dolphinrc"
copy_file "$bundle_root/dolphin/green_static.qss" "$target_home/.config/dolphin-green_static.qss"
copy_file "$bundle_root/dolphin/dolphin-wrapper.sh" "$target_home/.local/bin/dolphin"
copy_file "$bundle_root/kde/kdeglobals" "$target_home/.config/kdeglobals"
copy_tree "$bundle_root/kde/color-schemes" "$target_home/.local/share/color-schemes"
copy_file "$bundle_root/green-static/themes/light/GreenStaticLight.colors" "$target_home/.local/share/color-schemes/GreenStaticLight.colors"
copy_file "$bundle_root/helpers/dunst_toggle.sh" "$target_home/.local/bin/dunst_toggle"
copy_file "$bundle_root/helpers/screenshot.sh" "$target_home/.local/bin/screenshot"
chmod +x "$target_home/.local/bin/"{dolphin,dunst_toggle,screenshot}

if [[ $with_extras == 1 ]]; then
  copy_tree "$bundle_root/extras/config" "$target_home/.config"
  copy_tree "$bundle_root/extras/background" "$target_home/code/backgrounds/cycling/ghibli"
fi

if [[ -f "$target_home/.mozilla/firefox/profiles.ini" ]]; then
  while IFS= read -r profile_path; do
    [[ -n "$profile_path" ]] || continue
    case "$profile_path" in
      /*) target="$profile_path" ;;
      *) target="$target_home/.mozilla/firefox/$profile_path" ;;
    esac
    # Only install profiles inside the requested home, including in staging mode.
    if [[ "$(realpath -m "$target")" != "$(realpath -m "$target_home")/"* ]]; then
      echo "Skipping Firefox profile outside target home: $target" >&2
      continue
    fi
    copy_file "$bundle_root/firefox/userChrome.css" "$target/chrome/userChrome.css"
    copy_file "$bundle_root/firefox/userContent.css" "$target/chrome/userContent.css"
    # Preserve existing Firefox preferences; append the theme preferences last.
    prefs=$(mktemp)
    if [[ -f "$target/user.js" ]]; then cat "$target/user.js" > "$prefs"; fi
    printf '\n' >> "$prefs"
    cat "$bundle_root/firefox/user.js" >> "$prefs"
    copy_file "$prefs" "$target/user.js"
    rm -f "$prefs"
  done < <(awk -F= '/^Path=/{sub(/\r$/, "", $2); print $2}' "$target_home/.mozilla/firefox/profiles.ini")
fi

copy_file "$bundle_root/hypr/hyprland.conf" "$target_home/.config/hypr/hyprland.conf"
copy_file "$bundle_root/hypr/hyprland.lua" "$target_home/.config/hypr/hyprland.lua"

printf 'Green Static installed in %s\nBackups of replaced files: %s\n' "$target_home" "$backup_root"
printf '%s\n' 'No explicit application reloads were requested; Hyprland may reload automatically. See INSTALLATION.md for activation and checks.'
