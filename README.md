# Service Tray

**Service Tray** is a lightweight tray application for Linux that allows you to monitor and control systemd services directly from your desktop. It shows a status icon (green/red) depending on whether services are active and provides a right-click menu to toggle, refresh, or quit services.

---

## Features

- **Tray Icon:**  
  - **Green** if at least one service is running.  
  - **Red** if all services are stopped.  
- **Dynamic Menu:**  
  - Lists services from a configuration file.  
  - Right-click menu includes `Refresh Services` and `Quit`.  
- **Automatic Updates:**  
  - Icon and service status update every 5 seconds.  
- **Easy Autostart:**  
  - Installs itself to start at user login.  
- **Sudo Security:**  
  - User types password only once per session when toggling services.  

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/service-tray.git
cd service-tray
```

### 2. Run the Installer

```bash
./install.sh
```

This will:

- Install all necessary dependencies for Debian/Ubuntu, Arch/Manjaro, or Fedora.
- Make `service-tray.py` executable.
- Copy default icons to the `icons` directory.
- Create an autostart entry so Service Tray launches at login.
- Launch Service Tray immediately.

---

## Configuration

The list of services is defined in `services.conf` in the project directory.

Format:

```
Display Name = systemd-service-name
```

Example:

```
Whisper = whisper.service
Forge = forge.service
Ollama = ollama.service
```

- Lines starting with `#` are ignored.  
- To add or remove services, edit this file and then right-click the tray icon and select **Refresh Services**.

---

## Icons

- Default icons are located in `default_icons`.  
- Custom icons can be placed in `icons` directory:  
  - `green.png` – icon when at least one service is running  
  - `red.png` – icon when all services are stopped  

---

## Usage

- **Toggle Service:** Left-click a service in the menu to start/stop it.  
- **Refresh Services:** Right-click → **Refresh Services** to reload `services.conf`.  
- **Quit:** Right-click → **Quit** to exit the application.  

---

## Requirements

- Python 3.x  
- Linux with systemd  
- GTK3 and AppIndicator support  

Dependencies are automatically installed via `install.sh`:

- Debian/Ubuntu: `python3-gi`, `gir1.2-appindicator3-0.1`, `libcairo2-dev`, `libgirepository-1.0-dev`, `gobject-introspection`, `pkg-config`, `python3-dev`, `python3-pip`  
- Arch/Manjaro: `python-gobject`, `libappindicator-gtk3`, `python-pip`  
- Fedora: `python3-gobject`, `libappindicator-gtk3`, `python3-pip`  

---

## Security

- Service Tray uses sudo to start/stop/restart services.  
- The first time a service is toggled, you will be prompted for your password.  
- After that, sudo rules are cached until the session ends.

---

## Development

1. Install development dependencies:

```bash
sudo apt install python3-gi gir1.2-appindicator3-0.1 python3-dev
```

2. Edit `service-tray.py` or `services.conf`.  
3. Test changes by running:

```bash
./service-tray.py
```

---

## License

This project is licensed under the MIT License.

---

## Contributing

1. Fork the repository.  
2. Make your changes.  
3. Submit a pull request.  
4. Ensure `install.sh` and README instructions are updated if needed.  

---

## Author

Your Name – [Your GitHub Profile](https://github.com/YOUR_USERNAME)