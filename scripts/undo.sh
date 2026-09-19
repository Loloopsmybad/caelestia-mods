#!/bin/bash
# Undo Caelestia mods — detects what's installed and asks what to remove
# Run: bash scripts/undo.sh

TARGET="/etc/xdg/quickshell/caelestia"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

PKG="$(python3 -c 'from pathlib import Path; import caelestia; print(Path(caelestia.__file__).resolve().parent)' 2>/dev/null)"
SITE="$(dirname "$PKG" 2>/dev/null)"
SCHEMES="$PKG/data/schemes"
THEME_PY="$PKG/utils/theme.py"
PATCH="$REPO_DIR/obsidian/apply.patch"

echo "Caelestia mods undo"
echo ""

# --- detect what's installed ---
GITHUB=false
if [ -f "$TARGET/services/GitHub.qml" ] || grep -q "GitHub;" "$TARGET/modules/ServiceLoader.qml" 2>/dev/null; then
    GITHUB=true
fi

THEMES_COUNT=0
if [ -d "$SCHEMES" ]; then
    for d in "$REPO_DIR/themes/schemes/"*/; do
        [ -d "$d" ] || continue
        if [ -d "$SCHEMES/$(basename "$d")" ]; then
            THEMES_COUNT=$((THEMES_COUNT + 1))
        fi
    done
fi

OBS=false
if [ -n "$PKG" ] && grep -q "def apply_obsidian" "$THEME_PY" 2>/dev/null; then
    OBS=true
fi

echo "Installed mods:"
echo "  1) GitHub dashboard mod   [ $([ "$GITHUB" = true ] && echo installed || echo not installed) ]"
echo "  2) Themes ($THEMES_COUNT scheme dirs installed)   [ $([ "$THEMES_COUNT" -gt 0 ] && echo installed || echo not installed) ]"
echo "  3) Obsidian theme hook    [ $([ "$OBS" = true ] && echo installed || echo not installed) ]"
echo ""

# --- prompt ---
while :; do
    read -rp "What do you want to remove? (numbers, e.g. '1 3'; 'a' = all; Enter = cancel) > " choice
    if [ -z "$choice" ]; then
        echo "Nothing removed."
        exit 0
    fi
    if [ "$choice" = "a" ]; then
        sel="1 2 3"
    else
        sel="$(echo "$choice" | tr ',' ' ')"
    fi
    valid=1
    for c in $sel; do
        case "$c" in
            1 | 2 | 3) ;;
            *) valid=0 ;;
        esac
    done
    if [ "$valid" = 1 ]; then
        break
    fi
    echo "Invalid selection: pick 1, 2, 3 (or 'a')."
done

restart_shell=false

# --- 1) GitHub dashboard mod ---
for c in $sel; do
    if [ "$c" = "1" ] && [ "$GITHUB" = true ]; then
        restart_shell=true
        echo ""
        echo "Removing GitHub dashboard mod ..."
        echo "  Removing services/GitHub.qml"
        echo "1111" | su -c "rm -f '$TARGET/services/GitHub.qml'"
        echo "  Removing modules/dashboard/GitHubTab.qml"
        echo "1111" | su -c "rm -f '$TARGET/modules/dashboard/GitHubTab.qml'"
        echo "  Removing modules/dashboard/dash/GitHub/ (sub-components)"
        echo "1111" | su -c "rm -rf '$TARGET/modules/dashboard/dash/GitHub'"
        echo "  Restoring modules/ServiceLoader.qml"
        echo "1111" | su -c "sed -i '/GitHub;/d' '$TARGET/modules/ServiceLoader.qml'"

        echo "  Restoring modules/dashboard/Content.qml"
        python3 << 'PYEOF'
import re

path = "/etc/xdg/quickshell/caelestia/modules/dashboard/Content.qml"
with open(path) as f:
    text = f.read()

# Remove the GitHub tab entry from dashboardTabs
text = re.sub(
    r'\n\s*\{\n\s*component: githubComponent,\n\s*iconName: "code",\n\s*text: qsTr\("GitHub"\),\n\s*enabled: true\n\s*\}',
    '',
    text,
    count=1
)
# Remove the githubComponent Component block
text = re.sub(
    r'\n\s*Component \{\n\s*id: githubComponent\n[\s\S]*?\n\s*\}',
    '',
    text,
    count=1
)
with open(path, "w") as f:
    f.write(text)
print("  Content.qml restored")
PYEOF

    elif [ "$c" = "1" ] && [ "$GITHUB" != true ]; then
        echo "  [skip] GitHub mod not installed"
    fi
done

# --- 2) Themes ---
for c in $sel; do
    if [ "$c" = "2" ] && [ "$THEMES_COUNT" -gt 0 ]; then
        echo ""
        echo "Removing $THEMES_COUNT scheme dirs from $SCHEMES ..."
        tmp="$(mktemp)"
        for d in "$REPO_DIR/themes/schemes/"*/; do
            [ -d "$d" ] || continue
            [ -d "$SCHEMES/$(basename "$d")" ] && basename "$d" >> "$tmp"
        done
        echo "1111" | su -c "while IFS= read -r name; do rm -rf \"$SCHEMES/\$name\" 2>/dev/null; done < '$tmp'; rm -f '$tmp'"
        echo "  Removed $THEMES_COUNT theme dirs."
        echo "  Note: stock caelestia schemes were part of the installed set; a full stock restore needs a caelestia package update."
    elif [ "$c" = "2" ] && [ "$THEMES_COUNT" = 0 ]; then
        echo "  [skip] themes not installed"
    fi
done

# --- 3) Obsidian theme hook ---
for c in $sel; do
    if [ "$c" = "3" ] && [ "$OBS" = true ]; then
        echo ""
        echo "Removing Obsidian theme hook ..."

        if echo "1111" | su -c "cd '$SITE' && patch -p1 -R --dry-run < '$PATCH'" >/dev/null 2>&1; then
            echo "  Restoring theme.py"
            echo "1111" | su -c "cd '$SITE' && patch -p1 -R < '$PATCH'" >/dev/null 2>&1
            echo "  theme.py restored"
        else
            echo "  [warn] theme.py differs from the installed patch, skipping auto-restore."
            echo "         Restore by reinstalling/updating the caelestia package."
        fi

        python3 << 'PYEOF'
import json
from pathlib import Path

# Remove enableObsidian from the caelestia config
cfg_path = Path.home() / ".config/caelestia/cli.json"
try:
    cfg = json.loads(cfg_path.read_text())
except (OSError, json.JSONDecodeError):
    cfg = {}
theme = cfg.get("theme")
if isinstance(theme, dict) and "enableObsidian" in theme:
    del theme["enableObsidian"]
    cfg_path.write_text(json.dumps(cfg, indent=2))
    print("  enableObsidian removed from %s" % cfg_path)

# Remove installed theme from vaults and reset appearance.json
obs = Path.home() / ".config/obsidian/obsidian.json"
try:
    vaults = json.loads(obs.read_text()).get("vaults", {})
except (OSError, json.JSONDecodeError):
    vaults = {}

import shutil
for meta in vaults.values():
    vault = Path(meta["path"]) / ".obsidian"
    themes_dir = vault / "themes" / "Caelestia"
    if themes_dir.exists():
        shutil.rmtree(themes_dir)
        print("  removed %s" % themes_dir)
    ap = vault / "appearance.json"
    try:
        appearance = json.loads(ap.read_text())
    except (OSError, json.JSONDecodeError):
        continue
    if appearance.get("cssTheme") == "Caelestia":
        appearance["cssTheme"] = ""
        appearance.pop("accentColor", None)
        appearance.pop("theme", None)
        ap.write_text(json.dumps(appearance))
        print("  reset %s" % ap)
PYEOF

    elif [ "$c" = "3" ] && [ "$OBS" != true ]; then
        echo "  [skip] obsidian hook not installed"
    fi
done

echo ""
echo "Done."
if [ "$restart_shell" = true ]; then
    echo "Restart the shell: pkill -f 'qs.*caelestia'; sleep 2; qs -c caelestia -d"
fi