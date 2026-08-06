#!/bin/bash

export QT_QPA_PLATFORMTHEME=kde
export KDE_COLOR_SCHEME_PATH=/home/nuus/.local/share/color-schemes/GreenStatic.colors

exec /usr/bin/dolphin -stylesheet /home/nuus/.config/dolphin-green_static.qss "$@"
