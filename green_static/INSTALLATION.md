# Installation

## Goal

`green_static` is intended to be copyable to another machine and applied as a full profile bundle.

Preferred install method:

```bash
cd ~/code/.dotfiles/green_static
./apply.sh
```

The script copies files into the correct locations under the current user's home directory and rewrites bundled `/home/nuus/...` paths automatically.

## What The Bundle Covers

This bundle contains live config for:

- Dolphin
- KDE color scheme / globals
- Hyprland
- Awww wallpaper daemon
- Hypridle
- Hyprlock
- Waybar
- Kitty
- Dunst
- Wofi
- GTK 3
- Neovim
- Firefox `userChrome.css`, `userContent.css`, and `user.js`

## Runtime Prerequisites

Install or provide these before applying the theme:

- `hyprland`
- `awww`
- `awww-daemon` (normally provided by the `awww` package)
- `hypridle`
- `hyprlock`
- `hyprsunset`
- `waybar`
- `kitty`
- `dunst`
- `wofi`
- `wf-recorder`
- `dolphin`
- `jq`
- `python3`
- `grim`
- `slurp`
- `swappy`
- `brightnessctl`
- `playerctl`
- `pavucontrol`
- `libnotify` or another package that provides `notify-send`
- `firefox` (optional, only for the bundled `userChrome.css`)
- `neovim` (optional, only for the bundled theme override)

## Optional App Integrations

These are not required for the theme to apply, but the Hyprland config includes dedicated special-workspace treatment for them:

- `slack`
- `obsidian`
- `signal-desktop`

If they are not installed, the keybinds still exist, but `on-created-empty` will not be able to launch the apps automatically.

## Font Prerequisites

The current bundle expects these font families to exist:

- `BlexMono Nerd Font Mono`
- `JetBrains Mono`

At minimum, install a Nerd Font package that provides `BlexMono Nerd Font Mono`, because Waybar, Dunst, and Wofi rely on it.

## PATH Assumption

The bundle installs helper commands into:

- `~/.local/bin`

Your session should have `~/.local/bin` on `PATH`.

## Installed Helper Commands

`apply.sh` installs these bundled helpers into `~/.local/bin`:

- `dunst_toggle`
- `screenshot`
- `dolphin` (wrapper that applies the Dolphin-specific QSS)

These commands are referenced by the live config after install.

## Manual Apply (If You Do Not Use `apply.sh`)

You can still copy files manually, but `apply.sh` is recommended because it rewrites absolute home-directory paths.

If you apply manually, you must also update hardcoded `/home/nuus/...` paths in copied text files.

Minimum manual copy set:

```bash
cp ~/code/.dotfiles/green_static/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
cp ~/code/.dotfiles/green_static/hypr/hypridle.conf ~/.config/hypr/hypridle.conf
cp ~/code/.dotfiles/green_static/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf
cp ~/code/.dotfiles/green_static/hypr/glitch-launch.sh ~/.config/hypr/glitch-launch.sh
cp ~/code/.dotfiles/green_static/hypr/toggle-record.sh ~/.config/hypr/toggle-record.sh
cp ~/code/.dotfiles/green_static/hypr/awww_start.sh ~/.config/hypr/awww_start.sh
cp ~/code/.dotfiles/green_static/hypr/awww_cycle_once.sh ~/.config/hypr/awww_cycle_once.sh
cp ~/code/.dotfiles/green_static/hypr/awww_cycle.sh ~/.config/hypr/awww_cycle.sh
cp ~/code/.dotfiles/green_static/hypr/awww_monitor_listener.sh ~/.config/hypr/awww_monitor_listener.sh
cp ~/code/.dotfiles/green_static/hypr/awww_set_wallpaper.sh ~/.config/hypr/awww_set_wallpaper.sh
cp ~/code/.dotfiles/green_static/hypr/crt_cycle.sh ~/.config/hypr/crt_cycle.sh
cp ~/code/.dotfiles/green_static/hypr/toggle-crt.sh ~/.config/hypr/toggle-crt.sh
cp ~/code/.dotfiles/green_static/hypr/wallpaper.jpg ~/.config/hypr/wallpaper.jpg
cp ~/code/.dotfiles/green_static/hypr/shaders/*.frag ~/.config/hypr/shaders/
mkdir -p ~/code/backgrounds/cycling/ff7
cp ~/code/.dotfiles/green_static/wallpapers/ff7/* ~/code/backgrounds/cycling/ff7/
cp ~/code/.dotfiles/green_static/waybar/config ~/.config/waybar/config
cp ~/code/.dotfiles/green_static/waybar/style.css ~/.config/waybar/style.css
cp ~/code/.dotfiles/green_static/waybar/special_workspace.sh ~/.config/waybar/special_workspace.sh
cp ~/code/.dotfiles/green_static/waybar/recording_status.sh ~/.config/waybar/recording_status.sh
cp ~/code/.dotfiles/green_static/waybar/mic_status.sh ~/.config/waybar/mic_status.sh
cp ~/code/.dotfiles/green_static/dolphin/dolphinrc ~/.config/dolphinrc
cp ~/code/.dotfiles/green_static/dolphin/green_static.qss ~/.config/dolphin-green_static.qss
mkdir -p ~/.local/bin
cp ~/code/.dotfiles/green_static/dolphin/dolphin-wrapper.sh ~/.local/bin/dolphin
cp ~/code/.dotfiles/green_static/kde/kdeglobals ~/.config/kdeglobals
mkdir -p ~/.local/share/color-schemes
cp ~/code/.dotfiles/green_static/kde/color-schemes/GreenStatic.colors ~/.local/share/color-schemes/GreenStatic.colors
cp ~/code/.dotfiles/green_static/kitty/kitty.conf ~/.config/kitty/kitty.conf
cp ~/code/.dotfiles/green_static/dunst/dunstrc ~/.config/dunst/dunstrc
cp ~/code/.dotfiles/green_static/wofi/config ~/.config/wofi/config
cp ~/code/.dotfiles/green_static/wofi/style.css ~/.config/wofi/style.css
cp ~/code/.dotfiles/green_static/gtk-3.0/gtk.css ~/.config/gtk-3.0/gtk.css
cp ~/code/.dotfiles/green_static/nvim/lua/plugins/theme.lua ~/.config/nvim/lua/plugins/theme.lua
```

For Firefox, copy the bundled files into each profile’s `chrome/` directory:

```bash
mkdir -p ~/.mozilla/firefox/<profile>/chrome
cp ~/code/.dotfiles/green_static/firefox/userChrome.css ~/.mozilla/firefox/<profile>/chrome/userChrome.css
cp ~/code/.dotfiles/green_static/firefox/userContent.css ~/.mozilla/firefox/<profile>/chrome/userContent.css
cp ~/code/.dotfiles/green_static/firefox/user.js ~/.mozilla/firefox/<profile>/user.js
```

## Post-Apply Reload

Run these after applying the bundle:

```bash
hyprctl reload
pkill waybar; waybar >/dev/null 2>&1 &
dunstctl reload ~/.config/dunst/dunstrc
```

Then:

- restart or re-open `dolphin` to apply the wrapper + QSS + KDE colors
- reopen Wofi to pick up its CSS/config changes
- open a new Kitty window to verify the shader pulse still works
- verify `awww` is active by running `awww query`
- restart Firefox to apply `userChrome.css` and `userContent.css`
- restart Neovim or run `nvim --headless "+qa"` to validate the config

## Firefox Requirement

This bundle includes a `firefox/user.js` file that forces:

- `toolkit.legacyUserProfileCustomizations.stylesheets = true`

Firefox must be fully restarted after adding or changing that file.

## Validation Checklist

After installation, verify at least:

- `hyprctl reload` succeeds
- `jq empty ~/.config/waybar/config`
- `dunstctl reload ~/.config/dunst/dunstrc`
- `awww query` shows `~/.config/hypr/wallpaper.jpg`
- `Mod+R` starts/stops recording and Waybar shows `[REC]`
- `Mod+S`, `Mod+O`, and `Mod+Z` toggle Slack / Obsidian / Signal special workspaces
- Wofi opens with screen dimming + glitch pulse
- `nvim --headless "+qa"`
