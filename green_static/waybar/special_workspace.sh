#!/bin/bash

print_state() {
  local name short label

  name=$(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .specialWorkspace.name // ""')

  if [ -z "$name" ] || [ "$name" = "null" ]; then
    printf '{"text":"","tooltip":"","class":"hidden"}\n'
    return
  fi

  short="${name#special:}"

  case "$short" in
    slack) label="S" ;;
    obsidian) label="O" ;;
    onepassword) label="P" ;;
    signal) label="Z" ;;
    *)
      label=$(printf '%s' "$short" | tr '[:lower:]' '[:upper:]' | tr -cd 'A-Z0-9' | cut -c1)
      [ -z "$label" ] && label="?"
      ;;
  esac

  printf '{"text":"[%s]","tooltip":"%s","class":"%s"}\n' "$label" "$name" "$short"
}

socket="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

print_state

if [ ! -S "$socket" ]; then
  while sleep 1; do
    print_state
  done
  exit 0
fi

while IFS= read -r event; do
  case "$event" in
    activespecial*|workspace*|focusedmon*|createworkspace*|destroyworkspace*|moveworkspace* )
      print_state
      ;;
  esac
done < <(
  exec python3 - "$socket" <<'PY'
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
)
