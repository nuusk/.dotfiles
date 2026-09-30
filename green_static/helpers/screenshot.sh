#!/bin/bash

# Take a region screenshot and open it for annotation.
geometry=$(slurp) || exit 0
[[ -n "$geometry" ]] || exit 0

tmpfile=$(mktemp --suffix .png) || exit 1
trap 'rm -f "$tmpfile"' EXIT
/usr/bin/grim -g "$geometry" "$tmpfile" || exit 1
if command -v satty >/dev/null 2>&1; then
  satty --floating-hack --filename "$tmpfile"
else
  swappy --file "$tmpfile"
fi
