# Optional workstation extras

Installed only by `apply.sh --with-extras`:

- Audacity preferences and plugin settings; recent-file/home paths removed.
- Locale (`en_US.UTF-8`) and KDE Qt integration. The locale must be generated.
- Synthetic bold/italic font rendering, Breeze GTK 2 and xsettingsd defaults.
- Against the Storm number-row to function-key mapping in `keyd/app.conf`;
  requires a separately configured keyd application mapper.
- Windows 95 Kitty palettes, available through Kitty's `include` directive.
- Neovim: Tab accepts completion, Enter falls back; `sg` searches the current
  directory and `sG` the project root; Ruff Python configuration and editor tweaks.
- `nvim/lua/config/tic80.lua` runs `make run` on Lua saves only if explicitly
  loaded with `require("config.tic80")`. It is not loaded automatically.
- Bash worktree/session helpers. Follow `config/bash/README.md` to activate via
  home-directory symlinks. `wr` uses force removal; review before enabling.
- Ghibli wallpaper, installed as the `ghibli` collection.
- Razer Naga Trinity Input Remapper presets and Warcraft III hotkeys; see below.
- WirePlumber's saved default output, USB Audio Speakers. Only the selected
  speaker node is included, without device-selection history.

These are workstation preferences, not prerequisites for the desktop theme.

## Naga and Warcraft III

Install Input Remapper separately and enable its system service:

```sh
sudo systemctl enable --now input-remapper
```

The presets are stored under
`~/.config/input-remapper-2/presets/Razer Razer Naga Trinity/`.
They expect the mouse's onboard side buttons to emit F1–F12, configured using
Synapse previously. The Moonlander and other devices are not remapped.
The empty Against the Storm preset leaves those onboard bindings intact.

**Super+Space → naga-on** activates **Warcraft III Control Groups**:

| Side button | Output |
| --- | --- |
| 1, 2 | Number-row 1, 2 |
| 3 | Unchanged F3 |
| 4–11 | Number-row 3, 4, 5, 6, 7, 8, 9, 0 |
| 12 | Backtick/tilde key |

**naga-off** stops the Naga remapping and restores F1–F12. Activation applies
to every application until stopped; switching games does not switch presets.
The older **Warcraft III** and **Warcraft III Grid** presets are retained as
manual alternatives. No preset is configured to autoload.

The downloaded Warcraft hotkeys are stored in
`~/.config/warcraft3-hotkeys/CustomKeys.txt`, with only hero selection changed
to T/G/B and inventory changed to numpad 1–6 (top row 1–2, middle 3–4, bottom 5–6).
Other commands retain the downloaded layout: Move Z, Stop S, Hold X, Attack A.

Exit Warcraft III, then install into the existing Steam prefix:

```sh
bash ~/.config/warcraft3-hotkeys/install.sh
```

The helper defaults to Steam shortcut prefix `2329597938/pfx`. For a different
installation, provide the Wine prefix directory explicitly:

```sh
WC3_PREFIX="$HOME/path/to/pfx" bash ~/.config/warcraft3-hotkeys/install.sh
```

The helper backs up the existing file before replacing it. Keep the in-game
keybinding preset set to **Custom**. In-game edits update the copy inside the
prefix; copy it back into this bundle if those changes should be saved here.
Running the helper again installs the bundled copy over any in-game edits.

## USB speaker preference

The optional state file selects
`alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink` as WirePlumber's default
output. Apply the state while WirePlumber is stopped or before its next session
starts. It only applies to machines exposing that same speaker node name.
