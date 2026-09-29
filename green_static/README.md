# Green Static

A portable Hyprland desktop with phosphor-green dark colors, a high-contrast
light alternative, compact monospace chrome, and short launcher shader pulses.

The Waybar sun/moon control switches Hyprland, Kitty, Waybar, Wofi, Dunst, GTK,
KDE, and Firefox's desktop appearance preference together. Light parchment with sepia accents is the default.

## Install

```sh
./apply.sh
# Also install optional workstation settings:
./apply.sh --with-extras
```

Existing files are backed up under `~/.local/state/green-static/backups/`.
The installer copies files without reloading running applications.
See [INSTALLATION.md](INSTALLATION.md) for dependencies, activation, and checks.

## Included

- Hyprland Lua config and legacy config, idle/lock settings, recording,
  workspace overview, worktree launcher, shaders, and screenshot helpers.
- Waybar, Kitty, Wofi, Dunst, GTK, Dolphin/KDE, Satty, Neovim colors, and Firefox.
- `green-static/`: light/dark palettes and the theme-switching script.
- `wallpapers/`: EarthBound, Zelda, and FF7 collections. Select a collection and
  interval in `~/.config/hypr/wallpaper.conf`; default: Warcraft sketches, 30 minutes.
- `extras/`: optional fi application settings, Neovim behavior tweaks, shell
  worktree/session helpers, Windows 95 Kitty palettes, and a Ghibli background.

Use `Super+A` for a region screenshot and `Super+Shift+A` for a window screenshot.
`Super+D` opens Wofi. `Super+Tab` opens the workspace overview. `Super+T` opens
worktree selection; set `WORKTREE_REPO` and `WORKTREE_ROOT` for your repository.

The portable monitor layout uses automatic placement. Customize it on each
machine; workstation snapshots retain their own geometry.

## Command console and accents

`Super+Space` opens the compact command console. It provides app
launching, command execution, workspace/window selection, worktree selection,
wallpaper collections, screenshots, and theme controls. The app and command
entries open their respective Wofi search modes.

`Super+Shift+B` cycles green, amber, violet, cyan, and sepia accents. `Super+D` opens the app selector; `Super+B` opens Firefox. Accent selection persists independently of light/dark mode.
The accent updates launcher selection, Waybar highlights, terminal colors,
notifications, GTK/KDE palette accents, and Hyprland borders. Base backgrounds
and text colors retain the Green Static palette; Firefox's custom chrome
continues to use its own light/dark styling.

```sh
~/.config/green-static/toggle-theme.sh accent amber
~/.config/green-static/toggle-theme.sh accent cycle
```

Edit `green-static/accents.json` to adjust the five named palettes. Each has
separate primary/secondary colors for dark and light mode. Reapply an accent
after editing. Installations start with the sepia accent.

Use the console's `light` / `dark` entries or the Waybar sun/moon control to
switch the entire desktop appearance. `toggle-theme.sh set light` selects pale
backgrounds and dark text across the themed components, independently of accent
color. GTK's dark preference follows this selection. Neovim reads the desktop
mode when starting; reopen it after switching. Applications with their own
forced appearance settings may also need to be set to follow the system.

The light variant uses parchment backgrounds and brown ink. Select the `sepia`
accent for bronze/brown highlights (`toggle-theme.sh accent sepia`). Kitty retains
90% opacity. Neovim reads both appearance and accent when it starts.

The `warcraft-sketches` wallpaper collection combines Warcraft II/III character
art and early WoW architecture studies. Source links are in its `SOURCES.md`.
Collections may include `display.conf` with `resize` and `fill_color` to preserve
portrait artwork without cropping. Existing collections keep their crop behavior.
