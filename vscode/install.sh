#!/bin/bash
# Install the Caelestia VS Code theme hook
# Run: bash vscode/install.sh
#
# Requires the Obsidian theme.py patch to be installed first:
#   bash obsidian/install.sh

set -e

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
theme["enableVscode"] = True
cfg["theme"] = theme

path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(json.dumps(cfg, indent=2))
print("[ok] enableVscode=true in %s" % path)
PYEOF

echo ""
echo "Done. VS Code will now follow the Caelestia colour scheme."
echo "Restart VS Code, then switch your scheme:"
echo "  caelestia scheme set -n Cyberpunk -f default -m dark"
echo ""
echo "Disable: set \"theme\": {\"enableVscode\": false} in ~/.config/caelestia/cli.json"
echo ""
echo "NOTE: If you haven't installed the Obsidian patch yet, run:"
echo "  bash obsidian/install.sh"
echo "That patches theme.py with apply_vscode support."
