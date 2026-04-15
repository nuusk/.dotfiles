#!/usr/bin/env bash

state="$(dunstctl is-paused)"
if [ "$1" = "toggle" ]; then
  if [ "$state" = "true" ]; then dunstctl set-paused false; else dunstctl set-paused true; fi
  state="$(dunstctl is-paused)"
fi

if [ "$state" = "true" ]; then
  icon=""
  cls="paused"
  tip="Notifications hidden"
else
  icon=""
  cls="active"
  tip="Notifications visible"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$icon" "$tip" "$cls"
