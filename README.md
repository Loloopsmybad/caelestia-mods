# caelestia-mods

Custom modifications for the [Caelestia](https://github.com/caelestia-dots/shell) Quickshell desktop shell on Hyprland.

---

## Directory Structure

```
caelestia-mods/
|
|-- mods/                    Quickshell mods (copied 1:1 into /etc/xdg/quickshell/caelestia/)
|   +-- github/              GitHub dashboard tab
|       |-- services/
|       |   +-- GitHub.qml   API service (profile, contributions, repos)
|       +-- modules/dashboard/
|           |-- Content.qml  Patched: adds GitHub tab to dashboard
|           |-- GitHubTab.qml
|           +-- dash/GitHub/
|               |-- ContributionGraph.qml
|               |-- ProfileHeader.qml
|               |-- PinnedRepos.qml
|               +-- RepoCard.qml
|
|-- themes/                  Scheme data
|   |-- schemes/             92 community palettes (Ayu Blue, Cyberpunk, ...)
|   +-- install.sh           Copies schemes into the caelestia CLI data dir
|
|-- obsidian/                Obsidian theme hook
|   |-- utils/theme.py       Patched theme.py with Obsidian hook
|   |-- apply.patch          Same change as a unified diff
|   |-- install.sh           Installs the hook + enables via config
|   +-- README.md            Usage + disabling
|
|-- vscode/                  VS Code theme hook
|   |-- theme.py             Standalone apply script (reference)
|   +-- install.sh           Enables the hook via config
|
+-- scripts/
    |-- deploy.sh            Deploy mods to system
    +-- undo.sh              Interactive uninstaller
```

---

## Quick Start

### Deploy Mods

```bash
bash scripts/deploy.sh
```

Copies Quickshell mods into `/etc/xdg/quickshell/caelestia/` (requires root).
Restart the shell afterwards:

```bash
pkill -f 'qs.*caelestia'; sleep 2; qs -c caelestia -d
```

### Undo

```bash
bash scripts/undo.sh
```

Interactive uninstaller — detects what's installed and lets you choose what to
remove (GitHub mod, themes, Obsidian hook, VS Code hook). Select numbers, `a`
for all, or Enter to cancel.

---

## Themes

92 community palettes converted to Caelestia scheme format (`.txt` key-value
pairs, organized as `scheme/flavour/mode.txt`). Includes Ayu, Catppuccin,
Everforest, Tokyo Night, Kanagawa, Aura, Cyberpunk, and more.

```bash
bash themes/install.sh        # install schemes
caelestia scheme list --names  # verify
```

### Credits

Color data converted from
[Noctalia community-palettes](https://github.com/noctalia-dev/community-palettes).
Palette colors remain property of their upstream authors: Catppuccin, Tokyo
Night, Everforest, Kanagawa, Rose Pine, Ayu, Nord, Gruvbox, Solarized, Dracula,
One Dark, Flexoki, Oxocarbon, and the Noctalia community contributors.

---

## App Integrations

### Obsidian

Hooks into `caelestia`'s `theme.py` so every `caelestia scheme set` writes the
active scheme into each vault listed in `~/.config/obsidian/obsidian.json`
(theme CSS + `appearance.json` mode/accent).

```bash
bash obsidian/install.sh
```

See [`obsidian/README.md`](obsidian/README.md) for details.

### VS Code

Same hook writes `workbench.colorCustomizations` and
`editor.tokenColorCustomizations` into `~/.config/Code/User/settings.json`.

```bash
bash vscode/install.sh
```

> **Requires** the Obsidian patch first — both hooks share `theme.py`.

**Disable:** set `"enableVscode": false` in `~/.config/caelestia/cli.json`.

---

## Notes

- Files under `/etc/xdg/quickshell/caelestia/` are overwritten on
  `caelestia-shell` package updates — re-run `deploy.sh` after updating.
- Theme/Obsidian/VS Code files in `site-packages` are overwritten on
  `caelestia` package updates — re-run the respective `install.sh` scripts.
- Per-mod config lives in `~/.config/caelestia/shell.json` (not overwritten).
- Change the tracked GitHub username in `mods/github/services/GitHub.qml`.
