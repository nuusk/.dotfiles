## system-configuration

This repository contains the configuration files and profiles for tools that I use.

It also contains reusable theme bundles.

- `green_static/`
  A portable Hyprland-centered theme/profile bundle with its own `README.md`, `INSTALLATION.md`, and `AGENTS.md`.
  Apply it from inside that directory with:

  ```bash
  cd ~/code/.dotfiles/green_static
  ./apply.sh
  ```

  See `green_static/INSTALLATION.md` for prerequisites and post-apply steps.

The structure represents my workstations. For example, in `fi`, you will find all the files corresponding to the configuration files on `fi`. Those files should be placed under $HOME directory on your system, so for example:
In `i3` folder the structure is as follows:
```
i3
├── i3
│   └── config
└── i3status
    └── i3status.conf
```

The same directory structure should be placed in your `$HOME` directory for `i3` configuration to work, so:

```
/home/ptak
├── i3
│   └── config
└── i3status
    └── i3status.conf
```
