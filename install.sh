#!/bin/bash
set -e

LOG_FILE="$(dirname "$0")/install.log"
echo "=== Service Tray Installation Log ===" > "$LOG_FILE"


echo "=== Installing Service Tray dependencies ==="

# ----------------------------
# Install system dependencies
# ----------------------------
if command -v apt >/dev/null 2>&1; then
    echo "Detected Debian/Ubuntu"
    sudo apt update
    sudo apt install -y python3-gi gir1.2-appindicator3-0.1 \
                        libcairo2-dev libgirepository-1.0-dev \
                        gobject-introspection pkg-config python3-dev python3-pip
    echo "Installed packages via apt: $installed" >> "$LOG_FILE"
elif command -v pacman >/dev/null 2>&1; then
    echo "Detected Arch/Manjaro"
    sudo pacman -Syu --noconfirm python-gobject libappindicator-gtk3 python-pip
elif command -v dnf >/dev/null 2>&1; then
    echo "Detected Fedora"
    sudo dnf install -y python3-gobject libappindicator-gtk3 python3-pip
else
    echo "Unsupported distro. Please install dependencies manually."
    exit 1
fi

# ----------------------------
# Make script executable
# ----------------------------
chmod +x "$(dirname "$0")/service-tray.py"

# ----------------------------
# Setup icons directory
# ----------------------------
ICON_DIR="$(dirname "$0")/icons"
DEFAULT_ICON_DIR="$(dirname "$0")/default_icons"
mkdir -p "$ICON_DIR"
cp -n "$DEFAULT_ICON_DIR"/* "$ICON_DIR"/ 2>/dev/null || true

# ----------------------------
# Setup autostart
# ----------------------------
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

DESKTOP_FILE="$AUTOSTART_DIR/service-tray.desktop"

cat > "$DESKTOP_FILE" <<EOL
[Desktop Entry]
Type=Application
Name=Service Tray
Comment=Tray application to monitor and control systemd services
Exec=$(realpath "$(dirname "$0")/service-tray.py")
Icon=$(realpath "$ICON_DIR/green.png")
Terminal=false
EOL
echo "Created autostart desktop entry: $DESKTOP_FILE" >> "$LOG_FILE"
# ----------------------------
# Launch Service Tray immediately
# ----------------------------
echo "Starting Service Tray..."
nohup "$(realpath "$(dirname "$0")/service-tray.py")" >/dev/null 2>&1 &

echo "✅ Installation complete!"
echo "Service Tray is now running and will start automatically at login."

