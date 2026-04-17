#!/usr/bin/env bash
set -euo pipefail

lock_dir="${XDG_RUNTIME_DIR:-/tmp}/green_static"
lock_file="$lock_dir/awww_monitor_listener.lock"
socket="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
setter="/home/nuus/.config/hypr/awww_set_wallpaper.sh"

mkdir -p "$lock_dir"
exec 9>"$lock_file"
flock -n 9 || exit 0

if [ ! -S "$socket" ]; then
  exit 0
fi

python3 - "$socket" <<'PY' | while IFS= read -r event; do
import socket
import sys

path = sys.argv[1]
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect(path)

with sock, sock.makefile() as stream:
    for line in stream:
        sys.stdout.write(line)
        sys.stdout.flush()
PY
  case "$event" in
    monitoradded*|monitorremoved*|monitor*|configreloaded*)
      sleep 0.3
      "$setter" >/dev/null 2>&1 || true
      ;;
  esac
done
