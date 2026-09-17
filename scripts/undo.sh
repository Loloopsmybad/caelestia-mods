#!/bin/bash
# Undo all deployed Caelestia mods (remove mod files, restore base files)
# Run: bash scripts/undo.sh

set -e

TARGET="/etc/xdg/quickshell/caelestia"

echo "Undoing Caelestia mods..."

# 1. Remove mod-owned files & dirs
echo "  Removing services/GitHub.qml"
echo "1111" | su -c "rm -f '$TARGET/services/GitHub.qml'"

echo "  Removing modules/dashboard/GitHubTab.qml"
echo "1111" | su -c "rm -f '$TARGET/modules/dashboard/GitHubTab.qml'"

echo "  Removing modules/dashboard/dash/GitHub/ (sub-components)"
echo "1111" | su -c "rm -rf '$TARGET/modules/dashboard/dash/GitHub'"

# 2. Remove GitHub from ServiceLoader.qml
echo "  Restoring modules/ServiceLoader.qml"
echo "1111" | su -c "sed -i '/GitHub;/d' '$TARGET/modules/ServiceLoader.qml'"

# 3. Remove GitHub tab from Content.qml
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

print("  Content.qml patched")
PYEOF

echo ""
echo "Done! Restart: pkill -f 'qs.*caelestia'; sleep 2; qs -c caelestia -d"