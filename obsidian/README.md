# Obsidian theme hook

Adds an `apply_obsidian()` step to `caelestia`'s `theme.py`. On every
`caelestia scheme set` it writes the current scheme into each Obsidian vault
listed in `~/.config/obsidian/obsidian.json`:

- `.obsidian/themes/Caelestia/theme.css` — the full theme (both
  `.theme-dark` and `.theme-light` blocks)
- `.obsidian/themes/Caelestia/manifest.json`
- `.obsidian/appearance.json` — sets `cssTheme`, base color scheme
  (`obsidian` = dark, `moonstone` = light) and `accentColor` to match the
  active scheme

## Install

```bash
bash obsidian/install.sh
```

Enables the hook by default (`enableObsidian: true` in
`~/.config/caelestia/cli.json`).

## Usage

Apply a scheme (or use the launcher):

```bash
caelestia scheme set -n Cyberpunk -f default -m dark
```

then restart Obsidian. The vault picks up the theme, mode, and accent from the
active Caelestia scheme.

## Disable

```json
{
  "theme": { "enableObsidian": false }
}
```

in `~/.config/caelestia/cli.json`.

## Files

- `utils/theme.py` — full patched file; overwrites
  `<site-packages>/caelestia/utils/theme.py`
- `apply.patch` — same change as a unified diff (`patch -p1` from the
  site-packages dir), for setups that already modified `theme.py`
- `install.sh` — copies the file and enables the hook

## Notes

- `site-packages` files are reset on `caelestia` package updates; re-run
  `install.sh` after updating.
- The theme only appears after Obsidian restarts.