# Installation

## Dependencies

Provide Hyprland with Lua configuration support, awww/awww-daemon, hypridle,
hyprlock, hyprsunset, Waybar, Kitty, Dunst, Wofi, wf-recorder, Dolphin, jq,
Python 3, grim, slurp, Satty, wl-clipboard, brightnessctl, playerctl,
pavucontrol, libnotify, util-linux (flock), and GNU coreutils/findutils.
KDE palette updates use `kwriteconfig6`; desktop appearance uses `gsettings`.
Install BlexMono Nerd Font Mono and JetBrains Mono. GTK settings expect Breeze
and its icons/cursors. Neovim integration expects an existing LazyVim setup.
Firefox and Neovim are optional. Slack, Obsidian, 1Password, and Signal have
special workspace shortcuts but are not installed by this bundle.

## Apply

```sh
./apply.sh
```

The installer copies into `~/.config`, `~/.local/bin`,
`~/.local/share/color-schemes`, and `~/code/backgrounds/cycling`.
Have `~/.local/bin` on PATH. Existing managed files are backed up under
`~/.local/state/green-static/backups/<timestamp>-<pid>/`, preserving their
relative paths. Restore selected files from that directory if needed.
Unrelated files are retained. Reapplying resets managed theme files to dark.
Hyprland entrypoints are installed last, after their theme and helper files,
because an active session may automatically reload when its config changes.
The installer does not explicitly reload applications.

Detected Firefox profiles inside the target home receive the chrome styles.
Theme preferences are appended to `user.js`, preserving other preferences.
Profiles outside that home are skipped; install their Firefox files manually.

To inspect an installation without changing your session:

```sh
./apply.sh --target-home /tmp/green-static-preview
```

## Optional workstation extras

```sh
./apply.sh --with-extras
```

This also installs Audacity settings (without recent-file paths), fontconfig,
locale/KDE environment settings, xsettingsd and GTK 2 defaults, the Against the
Storm keyd map, Windows 95 Kitty palettes, Bash worktree/session helpers, and
Neovim completion/search/Python configuration. It includes the Ghibli wallpaper.
See `extras/README.md` for behavior changes and manual activation. Extras may
overwrite existing application settings; review them before selecting this flag.

## Activation

When migrating from the legacy Hyprland config to Lua, log out and back in;
reloading an existing legacy session does not select the Lua entrypoint.
For an already active Lua session:

```sh
hyprctl reload
pkill -SIGUSR2 -x waybar
dunstctl reload
~/.config/green-static/toggle-theme.sh set dark
```

Start Waybar and the awww scripts if they are not running. Reopen Kitty, Wofi,
and Dolphin, and restart Firefox. Monitor positions are automatic by default;
adjust `~/.config/hypr/hyprland.lua` for your displays before activating.
The legacy `hyprland.conf` is retained as an alternative.

If an older installer triggered emergency mode with `module 'theme' not found`,
run `hyprctl reload` after installation finishes. Check `hyprctl configerrors`;
empty output means the configuration loaded successfully.

Change themes with Waybar or:

```sh
~/.config/green-static/toggle-theme.sh set light
~/.config/green-static/toggle-theme.sh set dark
```

Select `earthbound`, `zelda`, or `ff7` and an interval in seconds in
`~/.config/hypr/wallpaper.conf`. Wallpaper helpers notice changes automatically.

## Verification

- `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`
- `jq empty ~/.config/waybar/config`
- `awww query` and next/previous wallpaper shortcuts (`Super+M` / `Super+N`)
- `Super+R` recording toggle and Waybar recording status
- Region screenshot (`Super+A`) and window screenshot (`Super+Shift+A`)
- Copy from Satty, close it, then paste the image
- Open Kitty and Wofi; check shader pulses, dimming, and readability in both modes
- `command -v dolphin` resolves to `~/.local/bin/dolphin`
- `notify-send 'Green Static' 'Theme check'`
- `nvim --headless '+qa'` in your configured Neovim installation

An isolated installation verifies file placement and parsing; visual behavior,
clipboard persistence, and application reloads still need a live session check.
