#!/bin/bash
# Deploy all Caelestia mods
# Run: bash scripts/deploy.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="/etc/xdg/quickshell/caelestia"
MODS_DIR="$REPO_DIR/mods"

echo "Deploying Caelestia mods..."

for mod in "$MODS_DIR"/*/; do
    [ -d "$mod" ] || continue
    mod_name=$(basename "$mod")
    echo "  [$mod_name]"

    # Copy QML files, preserving directory structure
    find "$mod" -name "*.qml" -type f | while read -r file; do
        rel="${file#"$mod"}"
        dest="$TARGET/$rel"
        dir=$(dirname "$dest")
        echo "    $rel"
        echo "1111" | su -c "mkdir -p '$dir' && cp '$file' '$dest'"
    done

    # Copy QML services (singletons)
    find "$mod" -path "*/services/*.qml" -type f | while read -r file; do
        rel="${file#"$mod"}"
        dest="$TARGET/$rel"
        dir=$(dirname "$dest")
        echo "    $rel"
        echo "1111" | su -c "mkdir -p '$dir' && cp '$file' '$dest'"
    done
done

# Patch ServiceLoader if not already patched
SERVICELOADER="$TARGET/modules/ServiceLoader.qml"
if ! grep -q "GitHub" "$SERVICELOADER" 2>/dev/null; then
    echo "  [patch] ServiceLoader.qml"
    echo "1111" | su -c "sed -i '/Weather.reload();/a\\        GitHub;' '$SERVICELOADER'"
fi

echo ""
echo "Done! Restart: pkill -f 'qs.*caelestia'; sleep 2; qs -c caelestia -d"
