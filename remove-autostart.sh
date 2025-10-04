#!/bin/bash
set -e

echo "=== Removing Service Tray autostart ==="

AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/service-tray.desktop"

if [ -f "$DESKTOP_FILE" ]; then
    rm "$DESKTOP_FILE"
    echo "Removed autostart entry."
else
    echo "No autostart entry found."
fi

echo "✅ Service Tray autostart removed successfully. Application and dependencies remain intact."
