#!/bin/bash
# Quick fix: deploy the corrected Dash.qml
# Run: bash ~/Projects/liquidglass-staging/fix-dash.sh

echo "1111" | sudo -S cp /etc/xdg/quickshell/caelestia/modules/dashboard/Dash.qml /etc/xdg/quickshell/caelestia/modules/dashboard/Dash.qml.broken-bak
echo "1111" | sudo -S cp ~/Projects/liquidglass-staging/Dash.qml.fixed /etc/xdg/quickshell/caelestia/modules/dashboard/Dash.qml
echo "Done! Restart shell: caelestia shell -k && caelestia shell -d"
