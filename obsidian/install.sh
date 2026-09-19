#!/bin/bash
# Install the Caelestia Obsidian theme hook
# Run: bash obsidian/install.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_DIR/obsidian/utils/theme.py"

# Resolve the installed caelestia package dir
PKG="$(python3 -c 'from pathlib import Path; import caelestia; print(Path(caelestia.__file__).resolve().parent)' 2>/dev/null)"
if [ -z "$PKG" ]; then
    echo "error: caelestia python package not found"
    exit 1
fi

FILE="$PKG/utils/theme.py"

if [ ! -f "$FILE" ]; then
    echo "error: $FILE not found"
    exit 1
fi

echo "Installing Obsidian hook into $FILE ..."

if grep -q "def apply_obsidian" "$FILE" 2>/dev/null; then
    echo "  [skip] apply_obsidian already present"
else
    echo "1111" | su -c "cp '$SRC' '$FILE'"
    echo "  [ok] theme.py patched"
fi

# Enable the hook in caelestia config (~/.config/caelestia/cli.json)
python3 << 'PYEOF'
import json
from pathlib import Path

path = Path.home() / ".config/caelestia/cli.json"
try:
    cfg = json.loads(path.read_text())
except (OSError, json.JSONDecodeError):
    cfg = {}

theme = cfg.setdefault("theme", {})
theme["enableObsidian"] = True
cfg["theme"] = theme

path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(json.dumps(cfg, indent=2))
print("  [ok] enableObsidian=true in %s" % path)
PYEOF

echo ""
echo "Done. apply_colours now writes the Caelestia theme into every Obsidian vault"
echo "listed in ~/.config/obsidian/obsidian.json (.obsidian/themes/Caelestia/ +"
echo "appearance.json). Restart Obsidian to pick it up, then switch your scheme:"
echo "  caelestia scheme set -n Cyberpunk -f default -m dark"
echo ""
echo "Disable: set \"theme\": {\"enableObsidian\": false} in ~/.config/caelestia/cli.json"
echo "Note: files in site-packages are reset on caelestia package updates; re-run this script after updating."