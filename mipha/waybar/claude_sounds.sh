#!/usr/bin/env bash
# Toggle/report the Claude Code sound hook mute flag. Usage: claude_sounds.sh [toggle]

flag="$HOME/.claude/hooks/pikmin/muted"
if [ "$1" = "toggle" ]; then
  if [ -e "$flag" ]; then rm -f "$flag"; else touch "$flag"; fi
fi

if [ -e "$flag" ]; then
  icon=' '
  cls="muted"
  tip="Claude sounds muted"
else
  icon=' '
  cls="active"
  tip="Claude sounds on"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$icon" "$tip" "$cls"
