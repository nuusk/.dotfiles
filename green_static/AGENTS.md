# AGENTS

## Purpose

`green_static` is the portable bundle for the current terminal-first Hyprland theme.

Treat this directory as the reusable theme package.

## Source Of Truth

When changing the theme in the future, do not leave the bundle and live config diverged.

Preferred workflow:

1. update the file inside `~/code/.dotfiles/green_static/`
2. copy the same change into the live target under `~/.config/` (and Firefox profile dirs if needed)
3. reload the affected component

If you edit a live file first, back-port the same change into this bundle before finishing.

Also keep `apply.sh` and `INSTALLATION.md` aligned with the actual bundle contents. A theme bundle is not complete if it cannot be applied cleanly on another machine.

## Design Rules

Keep the theme consistent with its current identity:

- background: `#0a0e17`
- foreground: `#80ffcc`
- dim text: `#5ea488` or nearby phosphor green
- primary accent: `#00ff80`
- secondary accent: `#00e5ff`
- error accent: `#ff453a`
- subtle border: `#0d3326`
- compact spacing
- thin borders
- small radii only (`2px` to `4px`)
- no bubbly cards, pastel palettes, or soft consumer-app styling

## Motion Rules

- Hyprland motion should stay simple and snappy.
- `kitty` and `wofi` use short screen-shader pulses.
- Wofi dims the rest of the screen with a layer rule.
- Avoid adding long or theatrical animations.

## Typography Rules

- System chrome should stay monospace-first.
- Current UI stack centers around `BlexMono Nerd Font Mono`.
- Some shipped files still reference `JetBrains Mono`; keep that intentional and documented if you change it.

## Bundle Layout

- `hypr/` compositor, wallpaper, lock/idle, shaders, launcher pulse script
- `apply.sh` one-shot installer for the bundle
- `waybar/` bar config and styles
- `dolphin/` Dolphin config snapshot
  Dolphin uses a small app-specific QSS override plus a wrapper script installed to `~/.local/bin/dolphin` so details view stays readable and non-striped even outside a full KDE session.
- `kde/` KDE globals and color scheme for Dolphin / KDE apps
- `kitty/` terminal config
- `dunst/` notifications
- `wofi/` launcher
- `gtk-3.0/` GTK overrides
- `nvim/` Neovim theme override
- `firefox/` reusable `userChrome.css`
- `helpers/` helper scripts that are installed into `~/.local/bin` by `apply.sh`

## Apply Workflow

Preferred workflow on a target machine:

1. run `./apply.sh`
2. reload the session components

Minimum reload commands:

- `hyprctl reload`
- `pkill waybar; waybar >/dev/null 2>&1 &`
- `dunstctl reload ~/.config/dunst/dunstrc`

Wofi applies on next open.
Kitty picks up the config on new windows.
Firefox needs a restart.

## Validation Checklist

After theme changes, validate at least the following:

- `hyprctl reload`
- `jq empty ~/.config/waybar/config`
- `dunstctl reload ~/.config/dunst/dunstrc`
- `awww query`
- `nvim --headless "+qa"`
- open Kitty and verify border animation / shader pulse
- open Wofi and verify dimming, shader pulse, icon rendering, and row styling
- verify `dolphin` resolves to `~/.local/bin/dolphin`
- send a `notify-send` test notification

## Portability Notes

The bundle contains absolute `/home/nuus/...` paths because it was captured from a live profile.

`apply.sh` is responsible for rewriting those to the target `$HOME` during install.

If new files are added that contain home-directory paths, update `apply.sh` so those paths are rewritten too.
