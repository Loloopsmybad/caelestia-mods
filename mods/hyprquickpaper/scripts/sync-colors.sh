#!/bin/bash
# Sync hyprquickpaper border color with the current Hyprland scheme's primary color

SCHEME="/home/kanishk/.config/hypr/scheme/current.lua"
COLORS="/home/kanishk/.config/quickshell/hyprquickpaper/colors.json"

# Extract primary color from scheme (line like: primary = "a7c080")
PRIMARY=$(grep -oP '^\s*primary\s*=\s*"\K[^"]+' "$SCHEME" 2>/dev/null)

if [ -n "$PRIMARY" ]; then
    # Update colors.json with the primary color
    echo "{\"border_color\": \"#${PRIMARY}\"}" > "$COLORS"
fi
