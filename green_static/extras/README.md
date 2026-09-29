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

These are workstation preferences, not prerequisites for the desktop theme.
