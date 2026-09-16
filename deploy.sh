#!/bin/bash
# Deploy GitHub widget to Caelestia shell
# Run with: bash ~/Projects/liquidglass-staging/deploy.sh

set -e

STAGING="$HOME/Projects/liquidglass-staging"
TARGET="/etc/xdg/quickshell/caelestia"

echo "Deploying GitHub widget to Caelestia shell..."

# Copy service
echo "  Copying services/GitHub.qml..."
echo "1111" | sudo -S cp "$STAGING/services/GitHub.qml" "$TARGET/services/GitHub.qml"

# Copy dashboard components
echo "  Copying dashboard/dash/GitHubWidget.qml..."
echo "1111" | sudo -S cp "$STAGING/dashboard/dash/GitHubWidget.qml" "$TARGET/modules/dashboard/dash/GitHubWidget.qml"

echo "  Copying dashboard/dash/GitHub/ components..."
echo "1111" | sudo -S mkdir -p "$TARGET/modules/dashboard/dash/GitHub"
echo "1111" | sudo -S cp "$STAGING/dashboard/dash/GitHub/"*.qml "$TARGET/modules/dashboard/dash/GitHub/"

# Restore and patch Dash.qml
echo "  Patching Dash.qml..."
DASH_FILE="$TARGET/modules/dashboard/Dash.qml"

# Restore from backup if exists
if [ -f "$DASH_FILE.bak" ]; then
    echo "1111" | sudo -S cp "$DASH_FILE.bak" "$DASH_FILE"
fi

# Check if GitHubWidget is already added
if grep -q "GitHubWidget" "$DASH_FILE"; then
    echo "    GitHubWidget already in Dash.qml, skipping patch"
else
    echo "1111" | sudo -S cp "$DASH_FILE" "$DASH_FILE.bak"
    
    # Replace the Media Rect with Media + GitHubWidget
    echo "1111" | sudo -S sed -i '/Media {$/{
        N
        s/Media {\n        id: media/Media {\n            id: media/
    }' "$DASH_FILE"

    # Add GitHubWidget after the Media Rect
    echo "1111" | sudo -S sed -i '/id: media/a\
\
    Rect {\
        Layout.row: 2\
        Layout.column: 0\
        Layout.columnSpan: 5\
        Layout.fillWidth: true\
        Layout.preferredHeight: githubWidget.implicitHeight + Tokens.padding.large * 2\
\
        radius: Tokens.rounding.extraLarge\
\
        GitHubWidget {\
            id: githubWidget\
        }\
    }' "$DASH_FILE"

    echo "    Dash.qml patched successfully"
fi

# Patch ServiceLoader.qml to load GitHub on init
echo "  Patching ServiceLoader.qml..."
SERVICELOADER="$TARGET/modules/ServiceLoader.qml"

if grep -q "GitHub" "$SERVICELOADER"; then
    echo "    GitHub already in ServiceLoader, skipping"
else
    echo "1111" | sudo -S cp "$SERVICELOADER" "$SERVICELOADER.bak"
    echo "1111" | sudo -S sed -i '/Weather.reload();/a\        GitHub;' "$SERVICELOADER"
    echo "    ServiceLoader patched"
fi

echo ""
echo "Deployment complete!"
echo "Restart the shell with: caelestia shell -k && caelestia shell -d"
