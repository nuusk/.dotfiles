#!/bin/bash

# Select a visible window, capture it, and open it in Satty.
geometry=$(
  /usr/bin/hyprctl clients -j \
    | /usr/bin/jq -r '.[] | select(.mapped == true) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' \
    | /usr/bin/slurp
) || exit 0

[[ -n "$geometry" ]] || exit 0

tmpfile=$(mktemp --suffix .png) || exit 1
/usr/bin/grim -g "$geometry" "$tmpfile" \
  && /usr/bin/satty --floating-hack --filename "$tmpfile"
