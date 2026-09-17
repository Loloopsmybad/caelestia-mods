# caelestia-mods

Custom modifications for the [Caelestia](https://github.com/caelestia-dots/shell) Quickshell desktop shell on Hyprland.

## Layout

Each mod under `mods/<name>/` mirrors the Caelestia file tree
(`services/`, `modules/`) and is copied 1:1 into `/etc/xdg/quickshell/caelestia/`.

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
```

## Deploy

```bash
bash scripts/deploy.sh
```

Copies every mod into `/etc/xdg/quickshell/caelestia/` (needs the root
password; `sudo` may lock out, `su` is used instead). Restart the shell after:

```bash
pkill -f 'qs.*caelestia'; sleep 2; qs -c caelestia -d
```

## Undo

```bash
bash scripts/undo.sh
```

Removes every mod file from `/etc/xdg/quickshell/caelestia/` and restores the
two patched base files (`Content.qml`, `ServiceLoader.qml`). Restart the shell
after, same as above.

## Notes

- Files under `/etc/xdg/quickshell/caelestia/` are overwritten on
  `caelestia-shell` package updates — re-run `deploy.sh` after updating.
- Per-mod config lives in `~/.config/caelestia/shell.json` (not overwritten).
- Change the tracked GitHub username in `mods/github/services/GitHub.qml`.