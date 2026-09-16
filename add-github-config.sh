#!/bin/bash
# Add GitHub config to shell.json
# Run with: bash ~/Projects/liquidglass-staging/add-github-config.sh

set -e

CONFIG="$HOME/.config/caelestia/shell.json"

echo "Adding GitHub config to shell.json..."

python3 << 'PYEOF'
import json

config_path = "/home/kanishk/.config/caelestia/shell.json"

with open(config_path, "r") as f:
    config = json.load(f)

# Add GitHub config to dashboard section
if "dashboard" not in config:
    config["dashboard"] = {}

config["dashboard"]["github"] = {
    "enabled": True,
    "username": "kanishk",
    "showContributions": True,
    "showPinnedRepos": True,
    "showStats": True,
    "refreshInterval": 300000
}

with open(config_path, "w") as f:
    json.dump(config, f, indent=4)

print("GitHub config added successfully!")
PYEOF
