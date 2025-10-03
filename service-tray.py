#!/usr/bin/python3

import gi, subprocess, os
gi.require_version('Gtk', '3.0')
gi.require_version('AppIndicator3', '0.1')
from gi.repository import Gtk, GLib, AppIndicator3

# ----------------------------
# CONFIGURATION
# ----------------------------
ICON_DIR = os.path.join(os.path.dirname(__file__), "icons")
ICON_GREEN = os.path.join(ICON_DIR, "green.png")
ICON_RED = os.path.join(ICON_DIR, "red.png")
UPDATE_INTERVAL = 5  # seconds
CONFIG_FILE = os.path.join(os.path.dirname(__file__), "services.conf")

# ----------------------------
# HELPER FUNCTIONS
# ----------------------------
def read_services_config():
    """Read services.conf and return a dict of DisplayName: ServiceName"""
    services = {}
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as f:
            for line in f:
                line = line.strip()
                if line.startswith("#") or not line:
                    continue
                if "=" in line:
                    name, service = line.split("=", 1)
                    services[name.strip()] = service.strip()
    return services

def get_service_state(service_name):
    """Return 'active' or 'inactive'"""
    try:
        output = subprocess.check_output(
            ["systemctl", "is-active", service_name],
            stderr=subprocess.STDOUT
        ).decode().strip()
        return output
    except subprocess.CalledProcessError:
        return "inactive"

def toggle_service(service_name):
    """Toggle the service on/off"""
    state = get_service_state(service_name)
    action = "stop" if state == "active" else "start"
    subprocess.run(["sudo", "systemctl", action, service_name])

def update_sudoers():
    """Update /etc/sudoers.d/service-tray with NOPASSWD for listed services"""
    try:
        sudoers_file = "/etc/sudoers.d/service-tray"
        services = [service for service in read_services_config().values()]
        if not services:
            return
        rules = f"{os.getenv('USER')} ALL=(ALL) NOPASSWD: " + \
                ", ".join([f"/bin/systemctl {cmd} {srv}" for srv in services for cmd in ["start","stop","restart","status"]])
        subprocess.run(["sudo", "tee", sudoers_file], input=rules.encode(), check=True)
        subprocess.run(["sudo", "chmod", "440", sudoers_file], check=True)
    except Exception as e:
        print("Failed to update sudoers:", e)

# ----------------------------
# MENU BUILD
# ----------------------------
def build_menu():
    global menu, menu_items
    menu_items.clear()
    # Remove all existing items
    for child in menu.get_children():
        menu.remove(child)

    # Add dynamic service items
    services = read_services_config()
    for name, service in services.items():
        item = Gtk.MenuItem(label=f"{get_service_state(service).upper()} - {name}")
        item.connect("activate", lambda w, s=service: toggle_service(s))
        item.show()
        menu.append(item)
        menu_items.append(item)

    # Refresh Services menu item
    refresh_item = Gtk.MenuItem(label="Refresh Services")
    refresh_item.connect("activate", refresh_services)
    refresh_item.show()
    menu.append(refresh_item)

    # Quit menu item
    quit_item = Gtk.MenuItem(label="Quit")
    quit_item.connect("activate", lambda w: Gtk.main_quit())
    quit_item.show()
    menu.append(quit_item)

# ----------------------------
# REFRESH FUNCTION
# ----------------------------
def refresh_services(menu_item=None):
    update_sudoers()   # update sudoers for listed services
    build_menu()       # rebuild menu with new services

# ----------------------------
# UPDATE ICON FUNCTION
# ----------------------------
def update_icon():
    any_active = False
    services = read_services_config()
    for item, (name, service) in zip(menu_items, services.items()):
        state = get_service_state(service)
        item.set_label(f"{state.upper()} - {name}")
        if state == "active":
            any_active = True

    indicator.set_icon(ICON_GREEN if any_active else ICON_RED)
    return True  # Keep GLib timeout running

# ----------------------------
# INIT
# ----------------------------
menu_items = []

indicator = AppIndicator3.Indicator.new(
    "service-tray",
    ICON_RED,
    AppIndicator3.IndicatorCategory.APPLICATION_STATUS
)
indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)

menu = Gtk.Menu()

build_menu()
indicator.set_menu(menu)

# Start periodic updates
GLib.timeout_add_seconds(UPDATE_INTERVAL, update_icon)
update_icon()  # initial update

Gtk.main()

