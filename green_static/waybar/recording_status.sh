#!/usr/bin/env bash

if pgrep -x wf-recorder >/dev/null 2>&1; then
  printf '{"text":"[REC]","tooltip":"Screen recording active","class":"recording"}\n'
else
  printf '{"text":"","tooltip":"","class":"hidden"}\n'
fi
