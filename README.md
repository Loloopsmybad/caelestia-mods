# caelestia-mods

Custom modifications for the [Caelestia](https://github.com/caelestia-dots/shell) Quickshell desktop shell on Hyprland.

<p align="center">
  <img src="https://img.shields.io/badge/Hyprland-9FDAE0?style=for-the-badge&logo=hyprland&logoColor=white" alt="Hyprland"/>
  <img src="https://img.shields.io/badge/Quickshell-D4AF37?style=for-the-badge&logo=qt&logoColor=white" alt="Quickshell"/>
  <img src="https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visual-studio-code&logoColor=white" alt="VS Code"/>
  <img src="https://img.shields.io/badge/Obsidian-7C3AED?style=for-the-badge&logo=obsidian&logoColor=white" alt="Obsidian"/>
  <img src="https://img.shields.io/badge/92-Schemes-F59E0B?style=for-the-badge" alt="92 Schemes"/>
</p>

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

Interactive uninstaller.

Detects what's installed and lets you choose what to remove — GitHub mod, themes, Obsidian hook, or VS Code hook. Select numbers, `a` for all, or Enter to cancel.

---

## Themes

<p>
  <img src="https://img.shields.io/badge/Ayu-F59E0B?style=flat-square" alt="Ayu"/>
  <img src="https://img.shields.io/badge/Catppuccin-BA68C8?style=flat-square" alt="Catppuccin"/>
  <img src="https://img.shields.io/badge/Everforest-8DA101?style=flat-square" alt="Everforest"/>
  <img src="https://img.shields.io/badge/Tokyo_Night-7AA2F7?style=flat-square" alt="Tokyo Night"/>
  <img src="https://img.shields.io/badge/Kanagawa-D4935A?style=flat-square" alt="Kanagawa"/>
  <img src="https://img.shields.io/badge/Aura-A277FF?style=flat-square" alt="Aura"/>
  <img src="https://img.shields.io/badge/Cyberpunk-FCE100?style=flat-square" alt="Cyberpunk"/>
  <img src="https://img.shields.io/badge/-87_more-F472B6?style=flat-square" alt="87 more"/>
</p>

92 community palettes converted to Caelestia scheme format.

Schemes are `.txt` key-value pairs organized as `scheme/flavour/mode.txt`.

```bash
bash themes/install.sh        # install schemes
caelestia scheme list --names  # verify
```

### Credits

Color data converted from [Noctalia community-palettes](https://github.com/noctalia-dev/community-palettes).

Palette colors remain property of their upstream authors: Catppuccin, Tokyo Night, Everforest, Kanagawa, Rose Pine, Ayu, Nord, Gruvbox, Solarized, Dracula, One Dark, Flexoki, Oxocarbon, and the Noctalia community contributors.

---

## App Integrations

### Obsidian

<p>
  <img src="https://img.shields.io/badge/Hook-theme.py-7C3AED?style=for-the-badge" alt="theme.py"/>
  <img src="https://img.shields.io/badge/Config-enableObsidian-10B981?style=for-the-badge" alt="enableObsidian"/>
</p>

Hooks into `caelestia`'s `theme.py`.

Every `caelestia scheme set` writes the active scheme into each vault listed in `~/.config/obsidian/obsidian.json` — theme CSS + `appearance.json` mode/accent.

```bash
bash obsidian/install.sh
```

See [`obsidian/README.md`](obsidian/README.md) for details.

### VS Code

<p>
  <img src="https://img.shields.io/badge/Hook-theme.py-007ACC?style=for-the-badge" alt="theme.py"/>
  <img src="https://img.shields.io/badge/Config-enableVscode-10B981?style=for-the-badge" alt="enableVscode"/>
</p>

Same hook writes color customizations into `~/.config/Code/User/settings.json`.

Sets `workbench.colorCustomizations` and `editor.tokenColorCustomizations` — editor, sidebar, tabs, terminal, git decorations, and syntax highlighting all follow your Caelestia scheme.

```bash
bash vscode/install.sh
```

> **Note:** Requires the Obsidian patch first — both hooks share `theme.py`.

**Disable:** set `"enableVscode": false` in `~/.config/caelestia/cli.json`.

---

## Notes

<p>
  <img src="https://img.shields.io/badge/Warning-amber?style=flat-square" alt="Warning"/>
</p>

- Files under `/etc/xdg/quickshell/caelestia/` are overwritten on `caelestia-shell` package updates — re-run `deploy.sh` after updating.
- Theme/Obsidian/VS Code files in `site-packages` are overwritten on `caelestia` package updates — re-run the respective `install.sh` scripts.
- Per-mod config lives in `~/.config/caelestia/shell.json` (not overwritten).
- Change the tracked GitHub username in `mods/github/services/GitHub.qml`.
