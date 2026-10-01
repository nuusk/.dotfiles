# Wallpaper collections

Choose a collection in `~/.config/hypr/wallpaper.conf`:

```bash
collection=earthbound
interval=1800
```

Available collections: `earthbound` (5 maps), `zelda` (6 maps), `ff7` (4 wallpapers).
`paused-wallpapers` stores the remaining mixed backgrounds.

Magic collections contain only the largest desktop size, 2560×1600:

- `mtg-reality-fracture` — 8 wallpapers
- `mtg-the-hobbit` — 6 wallpapers
- `mtg-marvel-super-heroes` — 10 wallpapers

Select them from **Super+Space → wallpaper**, or set `collection` to the folder
name above. Each folder includes `sources.json` with original URLs and artist
credits. Numbered filenames preserve the order on the Magic wallpaper page.
Their `display.conf` selects `layout=blur`: full artwork centered over a dark,
matching blurred background, with soft side seams for ultrawide monitors.

Changes apply automatically within a few seconds. The interval is in seconds.
Next/previous wallpaper shortcuts use the selected collection too.
Create another folder here and set `collection` to its name to add a collection.
Supported files: PNG, JPG, JPEG, WebP, GIF. Files rotate in filename order.
