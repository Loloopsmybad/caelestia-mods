#!/bin/bash
# Install the Caelestia scheme themes into the CLI data dir
# Run: bash themes/install.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCHEMES_SRC="$REPO_DIR/themes/schemes"

# Resolve the schemes dir from the installed caelestia package
TARGET="$(python3 -c 'from pathlib import Path; import caelestia; print(Path(caelestia.__file__).resolve().parent / "data" / "schemes")' 2>/dev/null)"
if [ -z "$TARGET" ]; then
    TARGET="/usr/lib/python3.14/site-packages/caelestia/data/schemes"
fi

if [ ! -d "$SCHEMES_SRC" ]; then
    echo "error: $SCHEMES_SRC not found (missing themes/schemes/)"
    exit 1
fi

echo "Installing Caelestia scheme themes into $TARGET ..."

count=0
for dir in "$SCHEMES_SRC"/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    echo "  [$name]"
    echo "1111" | su -c "mkdir -p '$TARGET/$name' && cp -r '$dir/.' '$TARGET/$name/'"
    count=$((count + 1))
done

echo ""
echo "Installed $count themes."
echo "Verify: caelestia scheme list --names"
echo "Note: files in site-packages are reset on caelestia package updates; re-run this script after updating."