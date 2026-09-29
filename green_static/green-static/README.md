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

`Super+Shift+B` cycles green/amber/violet/cyan/sepia accents; `Super+B` opens Firefox.
Use `toggle-theme.sh accent amber` to select an accent directly. Palettes live
in `accents.json`; light/dark changes retain the selected accent.

Use the console's `light` / `dark` entries or the Waybar sun/moon control to
switch the entire desktop appearance. `toggle-theme.sh set light` selects pale
backgrounds and dark text across the themed components, independently of accent
color. GTK's dark preference follows this selection. Neovim reads the desktop
mode when starting; reopen it after switching. Applications with their own
forced appearance settings may also need to be set to follow the system.

The light variant uses parchment backgrounds and brown ink. Select the `sepia`
accent for bronze/brown highlights (`toggle-theme.sh accent sepia`). Kitty retains
90% opacity. Neovim reads both appearance and accent when it starts.
