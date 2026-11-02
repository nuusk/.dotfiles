#!/usr/bin/env bash
# Claude Code hook: plays a random Pikmin sound. Usage: pikmin.sh <category>
# Mute with: touch ~/.claude/hooks/pikmin/muted
dir="$(dirname "$(readlink -f "$0")")"
pack="$dir/packs/pikmin"
input="$(cat)"
[ -e "$dir/muted" ] && exit 0

file="$(jq -r --arg c "$1" '.categories[$c].sounds[].file' "$pack/openpeon.json" | shuf -n1)"
[ -n "$file" ] && pw-play --volume 0.5 "$pack/$file" &

project="$(jq -r '.cwd // "" | split("/") | last // ""' <<<"$input")"
case "$1" in
  input.required) notify-send "Claude Code" "$project — $(jq -r '.message // "Needs your input"' <<<"$input")" ;;
  task.complete) notify-send "Claude Code" "$project — Task complete" ;;
esac
wait
exit 0
