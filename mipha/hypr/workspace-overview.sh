#!/bin/bash
set -euo pipefail

prompt="${WORKSPACE_OVERVIEW_PROMPT:-Workspace / window}"
configured_special_workspaces=(
  "special:slack"
  "special:obsidian"
  "special:onepassword"
  "special:signal"
)

notify() {
  notify-send "Workspace overview" "$1" >/dev/null 2>&1 || true
}

workspaces_json="$(hyprctl -j workspaces)" || {
  notify "Could not read Hyprland workspaces"
  exit 1
}

clients_json="$(hyprctl -j clients)" || {
  notify "Could not read Hyprland windows"
  exit 1
}

active_workspace="$(hyprctl -j activeworkspace | jq -r '.name // ""' 2>/dev/null || true)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

normal_workspaces="$tmpdir/normal-workspaces"
special_workspaces="$tmpdir/special-workspaces"
menu="$tmpdir/menu"
actions="$tmpdir/actions"

{
  seq 1 10
  jq -r '.[] | (.name // "") | select(startswith("special:") | not)' <<<"$workspaces_json"
  jq -r '.[] | (.workspace.name // "") | select(startswith("special:") | not)' <<<"$clients_json"
} | awk 'NF' | sort -Vu >"$normal_workspaces"

{
  printf '%s\n' "${configured_special_workspaces[@]}"
  jq -r '.[] | (.name // "") | select(startswith("special:"))' <<<"$workspaces_json"
  jq -r '.[] | (.workspace.name // "") | select(startswith("special:"))' <<<"$clients_json"
} | awk 'NF' | sort -u >"$special_workspaces"

window_word() {
  if [ "$1" -eq 1 ]; then
    printf 'window'
  else
    printf 'windows'
  fi
}

append_workspace() {
  local workspace="$1"
  local count marker display

  count="$(jq --arg workspace "$workspace" '[.[] | select(.workspace.name == $workspace)] | length' <<<"$clients_json")"
  marker="[workspace]"
  if [ "$workspace" = "$active_workspace" ]; then
    marker="[current]"
  fi

  display="$(printf '%-11s %s  %s %s' "$marker" "$workspace" "$count" "$(window_word "$count")")"
  printf '%s\n' "$display" >>"$menu"
  printf '%s\tworkspace\t%s\n' "$display" "$workspace" >>"$actions"

  jq -r --arg workspace "$workspace" '
    .[]
    | select(.workspace.name == $workspace)
    | .address as $address
    | (.class // "unknown") as $class
    | (.title // "") as $title
    | ($title | gsub("[\t\r\n]+"; " ") | if length > 90 then .[0:87] + "..." else . end) as $safe_title
    | ($class | gsub("[\t\r\n]+"; " ")) as $safe_class
    | "\($safe_class)\t\($safe_title)\t\($address)"
  ' <<<"$clients_json" |
    while IFS=$'\t' read -r class title address; do
      if [ -n "$title" ]; then
        display="$(printf '[window]    %s  %s - %s [%s]' "$workspace" "$class" "$title" "$address")"
      else
        display="$(printf '[window]    %s  %s [%s]' "$workspace" "$class" "$address")"
      fi
      printf '%s\n' "$display" >>"$menu"
      printf '%s\twindow\t%s\n' "$display" "$address" >>"$actions"
    done
}

while IFS= read -r workspace; do
  append_workspace "$workspace"
done <"$normal_workspaces"

while IFS= read -r workspace; do
  append_workspace "$workspace"
done <"$special_workspaces"

selection="$(wofi --dmenu --prompt "$prompt" <"$menu" || true)"
if [ -z "$selection" ]; then
  exit 0
fi

action_line="$(awk -F '\t' -v selected="$selection" '$1 == selected { print; exit }' "$actions")"
if [ -z "$action_line" ]; then
  exit 0
fi

action="$(cut -f2 <<<"$action_line")"
target="$(cut -f3- <<<"$action_line")"

case "$action" in
  workspace)
    if [[ "$target" == special:* ]]; then
      hyprctl dispatch togglespecialworkspace "${target#special:}"
    else
      hyprctl dispatch workspace "$target"
    fi
    ;;
  window)
    hyprctl dispatch focuswindow "address:$target"
    ;;
esac
