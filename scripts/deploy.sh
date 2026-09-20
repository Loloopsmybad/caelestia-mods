#!/bin/bash
# Deploy all Caelestia mods
# Run: bash scripts/deploy.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="/etc/xdg/quickshell/caelestia"
MODS_DIR="$REPO_DIR/mods"
HYPRQUICKPAPER_TARGET="$HOME/.config/quickshell/hyprquickpaper"

echo "Deploying Caelestia mods..."

for mod in "$MODS_DIR"/*/; do
    [ -d "$mod" ] || continue
    mod_name=$(basename "$mod")

    # hyprquickpaper deploys to user config, not system-wide
    if [ "$mod_name" = "hyprquickpaper" ]; then
        echo "  [$mod_name] (user config)"
        mkdir -p "$HYPRQUICKPAPER_TARGET/components"
        mkdir -p "$HYPRQUICKPAPER_TARGET/scripts"

        # Copy QML files
        find "$mod" -name "*.qml" -type f | while read -r file; do
            rel="${file#"$mod"}"
            dest="$HYPRQUICKPAPER_TARGET/$rel"
            dir=$(dirname "$dest")
            echo "    $rel"
            mkdir -p "$dir" && cp "$file" "$dest"
        done

        # Copy shell scripts
        find "$mod" -name "*.sh" -type f | while read -r file; do
            rel="${file#"$mod"}"
            dest="$HYPRQUICKPAPER_TARGET/$rel"
            dir=$(dirname "$dest")
            echo "    $rel"
            mkdir -p "$dir" && cp "$file" "$dest"
            chmod +x "$dest"
        done

        # Copy JSON configs
        find "$mod" -name "*.json" -type f | while read -r file; do
            rel="${file#"$mod"}"
            dest="$HYPRQUICKPAPER_TARGET/$rel"
            dir=$(dirname "$dest")
            echo "    $rel"
            mkdir -p "$dir" && cp "$file" "$dest"
        done

        continue
    fi

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
