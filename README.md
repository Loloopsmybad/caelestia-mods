# caelestia-mods

Custom modifications for the [Caelestia](https://github.com/caelestia-dots/shell) Quickshell desktop shell on Hyprland, plus standalone Quickshell apps (hyprquickpaper).

## Layout

Quickshell mods live under `mods/<name>/`, mirror the Caelestia file tree
(`services/`, `modules/`) and are copied 1:1 into
`/etc/xdg/quickshell/caelestia/`. Standalone Quickshell apps (like
hyprquickpaper) deploy to `~/.config/quickshell/<name>/`. CLI-side additions
live at the top level: `themes/` (scheme data) and `obsidian/` (theme hook).

```
mods/
├── github/                  # GitHub dashboard tab
│   ├── services/
│   │   └── GitHub.qml       # API service (profile, contributions, repos)
│   └── modules/dashboard/
│       ├── Content.qml      # patched: adds GitHub tab to dashboard
│       ├── GitHubTab.qml    # main tab component
│       └── dash/GitHub/
│           ├── ContributionGraph.qml
│           ├── ProfileHeader.qml
│           ├── PinnedRepos.qml
│           └── RepoCard.qml
└── hyprquickpaper/           # wallpaper picker (standalone Quickshell app)
    ├── shell.qml             # entry point (PanelWindow + dock-style tile picker)
    ├── commands.sh            # awww wallpaper setter
    ├── cache.sh               # thumbnail cache builder (magick)
    ├── config.json            # wallpaper dir, cache path, tile size
    ├── colors.json            # border/accent color (synced from scheme)
    ├── components/
    │   ├── ColorsAdapter.qml  # colors.json reader
    │   ├── ConfigAdapter.qml  # config.json reader
    │   ├── PathFinder.qml     # wallpaper path resolver
    │   ├── Persistence.qml    # last-selected wallpaper memory
    │   ├── Selector.qml       # horizontal ListView with keyboard/wheel
    │   └── SelectorItem.qml   # tile delegate (zoom effect, shear, border)
    └── scripts/
        └── sync-colors.sh     # sync colors.json from scheme primary color
themes/
└── schemes/                 # 92 scheme palette dirs (Ayu Blue, Cyberpunk, ...)
    └── install.sh           # copy schemes into the caelestia CLI data dir
obsidian/
    ├── utils/theme.py       # patched theme.py with Obsidian hook
    ├── apply.patch          # same change as a unified diff
    ├── install.sh           # install the hook + enable via config
    └── README.md            # usage + disabling
```

## Deploy

```bash
bash scripts/deploy.sh
```

Copies Caelestia mods into `/etc/xdg/quickshell/caelestia/` (needs root
password; `su` is used instead of `sudo`). Hyprquickpaper is deployed as a
standalone app to `~/.config/quickshell/hyprquickpaper/`. Restart the shell
after:

```bash
pkill -f 'qs.*caelestia'; sleep 2; qs -c caelestia -d
```

## Undo

```bash
bash scripts/undo.sh
```

Detects what this repo has installed (GitHub dashboard mod, themes, Obsidian
hook, Hyprquickpaper) and interactively asks which to remove. For the GitHub
mod it deletes the mod files and restores the two patched base files
(`Content.qml`, `ServiceLoader.qml`); themes are pruned from
`<site-packages>/caelestia/data/schemes/`; the Obsidian hook reverses
`apply.patch` on `theme.py` (skipped with a warning if `theme.py` no longer
matches), drops `enableObsidian` from the caelestia config, and removes the
installed theme from each Obsidian vault; Hyprquickpaper removes
`~/.config/quickshell/hyprquickpaper/`. Select numbers, `a` for all, Enter to
cancel. Restart the shell after the GitHub item, same as above.

## Themes

92 community palettes converted to Caelestia scheme format (`.txt`, `key value`
pairs, organized `scheme/flavour/mode.txt`), including Ayu/x, Catppuccin
flavours, Everforest variants, Tokyo Night, Kanagawa, Aura, Cyberpunk, and
more. The full list is what `caelestia scheme list` returns on the original
setup.

Install (copies `themes/schemes/` into `<site-packages>/caelestia/data/schemes/`):

```bash
bash themes/install.sh
```

Verify:

```bash
caelestia scheme list --names
```

### Credits

The dark/light color data for these schemes was converted from the
[Noctalia community-palettes](https://github.com/noctalia-dev/community-palettes)
repo (per-palette JSON files → caelestia `key value` scheme files; the JSON
contains the palette colors only, no per-palette credits). That repo has no
license file, so the schemes' colors remain property of their upstream theme
authors, including: Catppuccin, Tokyo Night, Everforest, Kanagawa, Rose Pine,
Ayu, Nord, Gruvbox, Solarized, Dracula, One Dark, Flexoki, Oxocarbon, and the
community members who contributed palettes to Noctalia's repo.

## Obsidian

Adds an Obsidian theme hook to `caelestia`'s `theme.py`: every `caelestia
scheme set` writes the active scheme into each vault listed in
`~/.config/obsidian/obsidian.json` (theme CSS, `appearance.json` mode + accent).

```bash
bash obsidian/install.sh
```

See `obsidian/README.md` for usage and how to disable.

## Hyprquickpaper

Wallpaper picker launched with `Super+W`. Shows a horizontal dock of cached
thumbnails with zoom-on-hover, keyboard navigation, and wallpaper switching
via `awww`.

**Requirements:** `awww` and `awww-daemon` installed, `magick` (ImageMagick)
for thumbnail caching.

**Config:** `~/.config/quickshell/hyprquickpaper/config.json`

| Key | Default | Description |
|-----|---------|-------------|
| `wallpaper_path` | `~/Pictures/Wallpapers` | Directory to scan for wallpapers |
| `cache_path` | `~/.cache/quickshell/hyprquickpaper/` | Thumbnail cache dir |
| `number_of_pictures` | `6` | Tiles visible at once |
| `cache_batch_size` | `20` | Wallpapers cached per batch |
| `height` | `500` | Tile height in px |
| `border_color` | `#a7c080` | Selected tile border (synced from scheme) |
| `keep_open` | `true` | Keep picker open after selection |

**Sync colors from scheme:**

```bash
bash ~/.config/quickshell/hyprquickpaper/scripts/sync-colors.sh
```

Run after `caelestia scheme set` to update the border color to the active
scheme's primary.

## Notes

- Files under `/etc/xdg/quickshell/caelestia/` are overwritten on
  `caelestia-shell` package updates — re-run `deploy.sh` after updating.
- Scheme and Obsidian files in `site-packages` are overwritten on `caelestia`
  package updates — re-run `themes/install.sh` / `obsidian/install.sh` after
  updating.
- Hyprquickpaper lives in user config (`~/.config/quickshell/hyprquickpaper/`)
  — not overwritten by package updates, but also not shared across users.
- Per-mod config lives in `~/.config/caelestia/shell.json` (not overwritten).
- Change the tracked GitHub username in `mods/github/services/GitHub.qml`.