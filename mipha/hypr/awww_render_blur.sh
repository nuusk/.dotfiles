#!/usr/bin/env bash
# Fit the artwork over a dark, blurred backdrop derived from the same image.
set -euo pipefail
source_image="$1"
width="$2"
height="$3"
[[ "$width" =~ ^[1-9][0-9]*$ && "$height" =~ ^[1-9][0-9]*$ ]]
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/green-static/wallpapers"
mkdir -p "$cache_dir"
key=$( { sha256sum "$source_image"; printf '%s\n' "$width/$height/blur-v1"; } | sha256sum | cut -d' ' -f1)
target="$cache_dir/$key.png"
if [[ ! -s "$target" ]]; then
    temporary=$(mktemp "$cache_dir/.render-XXXXXX.png")
    trap 'rm -f -- "$temporary"' EXIT
    read -r fit_width fit_height < <(
        magick "$source_image" -auto-orient -resize "${width}x${height}" \
            -format '%w %h\n' info:
    )
    # Feather only the vertical seams when there is space beside the artwork.
    feather=0
    if (( fit_width < width )); then
        feather=$((fit_width / 40))
        (( feather > 0 )) || feather=1
    fi
    magick \
        \( "$source_image" -auto-orient -resize '10%' -blur 0x8 \
            -filter Lanczos -resize "${width}x${height}^" \
            -gravity center -extent "${width}x${height}" -modulate 35,90,100 \) \
        \( "$source_image" -auto-orient -filter Lanczos -resize "${fit_width}x${fit_height}!" \
            \( -size "${fit_width}x1" xc:white \
                -fx "${feather} == 0 ? 1 : min(1,min(i,w-1-i)/max(1,${feather}))" \
                -scale "${fit_width}x${fit_height}!" \) \
            -alpha off -compose CopyOpacity -composite \) \
        -gravity center -compose Over -composite -alpha off "$temporary"
    mv -- "$temporary" "$target"
    trap - EXIT
fi
printf '%s\n' "$target"
