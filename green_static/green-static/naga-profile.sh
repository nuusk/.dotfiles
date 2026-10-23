#!/usr/bin/env bash
set -euo pipefail

device='Razer Razer Naga Trinity'
profile='Warcraft III Control Groups'

case "${1:-}" in
  on)
    args=(--command start --device "$device" --preset "$profile")
    message='Warcraft control groups activated'
    ;;
  off)
    args=(--command stop --device "$device")
    message='Original F1–F12 mouse buttons restored'
    ;;
  *) printf 'Usage: %s on|off\n' "$0" >&2; exit 2 ;;
esac

if output=$(input-remapper-control "${args[@]}" 2>&1); then
  notify-send --app-name='Naga profile' 'Naga mouse' "$message"
else
  printf '%s\n' "$output" >&2
  notify-send --app-name='Naga profile' --urgency=critical 'Naga profile failed' "$output"
  exit 1
fi
