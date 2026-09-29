# Mipha workstation snapshot

Copy the application directories (bash, dunst, green-static, hypr, kitty,
nushell, nvim, waybar, and wofi) into `~/.config/`. Copy `starship.toml`
there too. Merge `.config/` into `~/.config/` and `.local/` into `~/.local/`.
See `bash/README.md` for the shell symlinks.

`hypr/hyprland.lua` contains the Lua configuration and loads `theme.lua`.
The legacy `hyprland.conf` is retained. Monitor layouts are machine-specific.
Helpers and shaders live directly under `hypr/`; Kitty image assets live
under `kitty/`.

Wallpaper rotation reads `hypr/wallpaper.conf`: `collection` selects a folder
under `~/code/backgrounds/cycling/`, and `interval` is in seconds. The current
selection is EarthBound at 30-minute intervals. Wallpaper collections remain
in the separate backgrounds repository and must be installed separately.

`green-static/` contains light/dark palettes and the theme switcher used by
Waybar. Install `dunst/dunstrc.base` with it. See `green-static/README.md` for
manual controls and Firefox setup. The saved theme files provide the initial
appearance; the switcher updates them when toggled.

The OpenCode directory remains a separately sanitized snapshot; see
`opencode/README.md` for credentials and authentication setup. Live account
configuration, caches, histories, and backup files are not part of this sync.
