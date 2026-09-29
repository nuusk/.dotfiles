#!/bin/bash

export QT_QPA_PLATFORMTHEME=kde

exec /usr/bin/dolphin -stylesheet $HOME/.config/dolphin-green_static.qss "$@"
