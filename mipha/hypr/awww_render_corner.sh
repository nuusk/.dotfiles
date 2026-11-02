#!/usr/bin/env bash
# Compose transparent artwork onto the desktop background, preserving source PNGs.
set -euo pipefail
source_image="$1"
width="$2"
height="$3"
background="$4"
[[ "$width" =~ ^[1-9][0-9]*$ && "$height" =~ ^[1-9][0-9]*$ ]]
[[ "$background" =~ ^[[:xdigit:]]{6}$ ]]
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/green-static/wallpapers"
mkdir -p "$cache_dir"
# Leave the upper/left desktop empty; anchor larger artwork flush to the corner.
size=$((height * 65 / 100))
(( size > width / 2 )) && size=$((width / 2))
margin=0
key=$( { sha256sum "$source_image"; printf '%s\n' "$width/$height/$background/corner-v2"; } | sha256sum | cut -d' ' -f1)
target="$cache_dir/$key.png"
if [[ ! -s "$target" ]]; then
    temporary=$(mktemp "$cache_dir/.render-XXXXXX.png")
    trap 'rm -f -- "$temporary"' EXIT
    magick -size "${width}x${height}" "xc:#$background" \
        \( "$source_image" -filter Lanczos -resize "${size}x${size}" \) \
        -gravity southeast -geometry "+${margin}+0" -compose over -composite \
        -alpha off "$temporary"
    mv -- "$temporary" "$target"
    trap - EXIT
fi
printf '%s\n' "$target"
