# Green Static

Green Static is a terminal-first Hyprland theme built around phosphor green on a void-black background.

The look is intentionally tighter and less "UI-card" than the original cyberpunk pass:

- deep black-blue backgrounds: `#0a0e17`
- phosphor foreground: `#80ffcc`
- primary active accent: `#00ff80`
- secondary cyan accent: `#00e5ff`
- subtle border green: `#0d3326`
- small radii, thin borders, compact spacing
- monospace system chrome
- snappy compositor motion
- short full-screen glitch pulses for `kitty` and `wofi`

## Character

This theme is closer to a cyberdeck / greenscreen terminal than a glossy neon dashboard.

- Waybar reads like a terminal HUD
- Dunst reads like a small terminal alert panel
- Wofi reads like a focused command palette
- Hyprland borders provide the most visible animated accent
- Neovim and Firefox inherit the same palette so the desktop stays coherent

## Included Components

- `hypr/`
  Hyprland config, wallpaper, `awww` wallpaper scripts, launcher pulse script, shaders, Hypridle, and Hyprlock files.
- `waybar/`
  Main bar config, CSS, and helper scripts for special-workspace / recording indicators.
- `dolphin/`
  Dolphin-specific config snapshot, QSS override, and wrapper script.
- `kde/`
  KDE globals and the `GreenStatic.colors` color-scheme file used by Dolphin.
- `kitty/`
  Terminal theme.
- `dunst/`
  Notification theme.
- `wofi/`
  Launcher config and styling.
- `gtk-3.0/`
  GTK color overrides.
- `nvim/`
  Neovim palette override.
- `firefox/`
  Profile-agnostic `userChrome.css` copy.
- `helpers/`
  External helper scripts that are installed into `~/.local/bin` by `apply.sh`.

## Apply

Preferred install path:

```bash
cd ~/code/.dotfiles/green_static
./apply.sh
```

`apply.sh` copies the profile into the current user's home, rewrites bundled `/home/nuus/...` paths to the target home directory, installs helper scripts into `~/.local/bin`, and updates all detected Firefox profiles.

## Notes

- The bundle is stored in the dotfiles repo at `~/code/.dotfiles/green_static`.
- Firefox styling is applied through both `userChrome.css` and `userContent.css`.
- See `INSTALLATION.md` for package prerequisites and post-apply reload steps.
