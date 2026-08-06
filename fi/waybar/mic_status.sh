#!/usr/bin/env bash

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q '\[MUTED\]'; then
  printf '{"text":"[MUTED]","tooltip":"Microphone muted","class":"muted"}\n'
else
  printf '{"text":"","tooltip":"","class":"hidden"}\n'
fi
