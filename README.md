

https://github.com/user-attachments/assets/d102d74c-db92-4697-805a-915f2dbbd0e9

# caelestia-mods

Custom modifications for the [Caelestia](https://github.com/caelestia-dots/shell) Quickshell desktop shell on Hyprland.

## What's here

### GitHub Dashboard Widget
A tab in the Caelestia dashboard showing your GitHub profile, contribution graph, and pinned repositories.

**Setup:**
1. Edit `services/GitHub.qml` — change `property string username: "Loloopsmybad"` to your GitHub username
2. Run `bash deploy.sh`
3. Restart shell: `caelestia shell -k && caelestia shell -d`

**Files:**
- `services/GitHub.qml` — API service (profile, contributions, repos)
- `dashboard/GitHubTab.qml` — Main tab component
- `dashboard/dash/GitHub/` — Sub-components (ContributionGraph, ProfileHeader, PinnedRepos, RepoCard)
- `dashboard/Content.qml` — Modified to add GitHub tab

## Deploy

```bash
bash deploy.sh
```

Requires sudo for `/etc/xdg/quickshell/caelestia/`. Uses `su` if `sudo` is locked.

## Notes

- Files in `/etc/xdg/quickshell/caelestia/` get overwritten on `caelestia-shell` package updates. Re-run `deploy.sh` after updates.
- Config lives in `~/.config/caelestia/shell.json` (not overwritten).
