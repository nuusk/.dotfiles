# Green Static light and dark themes

The Waybar moon/sun control switches Hyprland, Waybar, Kitty, Wofi, Dunst,
GTK, KDE applications, and the desktop appearance portal used by Firefox.

Light mode deliberately uses opaque surfaces and high-contrast text. Firefox
also needs one restart after the integration files are installed so it can
load the conditional light chrome stylesheet.

Manual controls:

```sh
~/.config/green-static/toggle-theme.sh toggle
~/.config/green-static/toggle-theme.sh set light
~/.config/green-static/toggle-theme.sh set dark
```

`Super+B` cycles green/amber/violet/cyan accents; `Super+Shift+B` opens Firefox.
Use `toggle-theme.sh accent amber` to select an accent directly. Palettes live
in `accents.json`; light/dark changes retain the selected accent.
