# myBackUpTool

![myBackUpTool Demo](myBackUpTool.gif)

A futuristic, automated backup utility for Linux with Google Drive integration.

## Features
- **Cloud Integration**: Uploads securely to Google Drive (or any `rclone` provider).
- **Unified Dashboard**: Real-time log streaming inside an animated progress bar.
- **Smart Zipping**: Compresses folders individually with clean, relative paths.
- **Expert Ignores**: Exclude heavy folders like `node_modules` or `.git` with a checklist UI.
- **Detailed Logging**: Captures specific error messages for easy debugging.
- **Scheduled Backups**: Built-in cron scheduler managed via Settings.
- **Telegram Notifications**: Instant alerts for successful backups (v1.5.0).

## Installation
1.  **Dependencies**:
    - **Linux** (Debian/Ubuntu): `sudo apt install dialog zip rclone`
    - **macOS** (Homebrew): `brew install dialog zip rclone`
    - **Windows** (WSL): Install a Linux distro and use `apt`.
2.  **Run**:
    ```bash
    chmod +x myBackUpTool.sh
    ./myBackUpTool.sh
    ```

## Configuration
1.  **Cloud Setup**: Go to **Settings > Setup Cloud Access** and follow the wizard to add your Google Drive (name it `gdrive`).
2.  **Select Remote**: Go to **Settings > Remote**, pick your provider, and optionally set a destination folder (default: `myBackUpTool_Data`).
3.  **Add Directories**: Go to **Dirs > Add** and browse to the folders you want to back up.
4.  **Automation**: Go to **Settings > Automation** to enable daily backups via cron.
5.  **Notifications**: Go to **Settings > Notifications** to configure Telegram alerts (Bot Token & Chat ID).

## Compatibility
This tool is designed to work on:
- **Linux**: Native support on most distributions (Ubuntu, Fedora, Arch, etc.).
- **macOS**: Fully functional via Terminal (requires Homebrew dependencies).
- **Windows**: Works seamlessly via **WSL** (Windows Subsystem for Linux) or Cygwin.

## Usage
- **Interactive**: Select **Backup** fro the main menu.
- **Automated**: Run `./myBackUpTool.sh --backup-all` (great for cron jobs).

## Themes
Change the look in **Settings > Theme**:
- Matrix (Green/Black)
- Retro (Amber/Black)
- Dracula (Purple/Dark)
- Oceanic (Cyan/Blue)
- Solarized Dark (Yellow/Blue/Base03)
- Monokai Pro (Pink/Green/Dark)
- Synthwave '84 (Neon Purple/Blue)

---
**Created by**: not_jarod
