#!/bin/bash
set -e

LOG_FILE="$(dirname "$0")/install.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "No install.log found! Cannot safely uninstall all."
    exit 1
fi

echo "=== Uninstalling Service Tray completely ==="

# ----------------------------
# Remove autostart
# ----------------------------
AUTOSTART_FILE=$(grep "Created autostart desktop entry" "$LOG_FILE" | awk '{print $NF}')
if [ -f "$AUTOSTART_FILE" ]; then
    rm "$AUTOSTART_FILE"
    echo "Removed autostart entry: $AUTOSTART_FILE"
fi

# ----------------------------
# Remove icons
# ----------------------------
ICON_DIR=$(grep "Copied default icons to" "$LOG_FILE" | awk '{print $NF}')
if [ -d "$ICON_DIR" ]; then
    rm -rf "$ICON_DIR"
    echo "Removed icons directory: $ICON_DIR"
fi

# ----------------------------
# Remove executable bit from Python script
# ----------------------------
if grep -q "Made service-tray.py executable" "$LOG_FILE"; then
    chmod -x "$(dirname "$0")/service-tray.py"
    echo "Removed executable permission from service-tray.py"
fi

# ----------------------------
# Uninstall packages
# ----------------------------
if grep -q "Installed packages via apt" "$LOG_FILE"; then
    packages=$(grep "Installed packages via apt" "$LOG_FILE" | sed 's/Installed packages via apt: //')
    if [ -n "$packages" ]; then
        echo "Removing packages installed via apt: $packages"
        sudo apt remove --purge -y $packages
        sudo apt autoremove -y
    fi
fi

# ----------------------------
# Remove log file
# ----------------------------
rm "$LOG_FILE"
echo "Removed installation log"

echo "✅ Complete uninstall finished. Only original files remain."

