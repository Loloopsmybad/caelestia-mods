# caelestia-mods

Custom modifications for the [Caelestia](https://github.com/caelestia-dots/shell) Quickshell desktop shell on Hyprland.

## Layout

Quickshell mods live under `mods/<name>/`, mirror the Caelestia file tree
(`services/`, `modules/`) and are copied 1:1 into
`/etc/xdg/quickshell/caelestia/`. CLI-side additions live at the top level:
`themes/` (scheme data), `obsidian/` (theme hook), and `vscode/` (theme hook).

```
mods/
└── github/                  # GitHub dashboard tab
    ├── services/
    │   └── GitHub.qml       # API service (profile, contributions, repos)
    └── modules/dashboard/
        ├── Content.qml      # patched: adds GitHub tab to dashboard
        ├── GitHubTab.qml    # main tab component
        └── dash/GitHub/
            ├── ContributionGraph.qml
            ├── ProfileHeader.qml
            ├── PinnedRepos.qml
            └── RepoCard.qml
themes/
└── schemes/                 # 92 scheme palette dirs (Ayu Blue, Cyberpunk, ...)
    └── install.sh           # copy schemes into the caelestia CLI data dir
obsidian/
    ├── utils/theme.py       # patched theme.py with Obsidian hook
    ├── apply.patch          # same change as a unified diff
    ├── install.sh           # install the hook + enable via config
    └── README.md            # usage + disabling
vscode/
    ├── theme.py             # standalone apply.py (unused, kept for reference)
    └── install.sh           # enable the hook via config
```

## Deploy

```bash
bash scripts/deploy.sh
```

Copies Caelestia mods into `/etc/xdg/quickshell/caelestia/` (needs root
password; `su` is used instead of `sudo`). Restart the shell after:

```bash
pkill -f 'qs.*caelestia'; sleep 2; qs -c caelestia -d
```

## Undo

```bash
bash scripts/undo.sh
```

Detects what this repo has installed (GitHub dashboard mod, themes, Obsidian
hook) and interactively asks which to remove. For the GitHub mod it deletes the
mod files and restores the two patched base files (`Content.qml`,
`ServiceLoader.qml`); themes are pruned from
`<site-packages>/caelestia/data/schemes/`; the Obsidian hook reverses
`apply.patch` on `theme.py` (skipped with a warning if `theme.py` no longer
matches), drops `enableObsidian` from the caelestia config, and removes the
installed theme from each Obsidian vault. Select numbers, `a` for all, Enter to
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

## VS Code

Adds a VS Code theme hook to `caelestia`'s `theme.py`: every `caelestia
scheme set` writes `workbench.colorCustomizations` and
`editor.tokenColorCustomizations` into `~/.config/Code/User/settings.json`.

```bash
bash vscode/install.sh
```

Requires the Obsidian patch to be installed first (both hooks share
`theme.py`). Disable: set `"enableVscode": false` in
`~/.config/caelestia/cli.json`.

## Notes

- Files under `/etc/xdg/quickshell/caelestia/` are overwritten on
  `caelestia-shell` package updates — re-run `deploy.sh` after updating.
- Scheme, Obsidian, and VS Code files in `site-packages` are overwritten on
  `caelestia` package updates — re-run `themes/install.sh` /
  `obsidian/install.sh` / `vscode/install.sh` after updating.
- Per-mod config lives in `~/.config/caelestia/shell.json` (not overwritten).
- Change the tracked GitHub username in `mods/github/services/GitHub.qml`.