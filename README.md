# myBackUpTool

A futuristic, automated backup utility for Linux with Google Drive integration.

## Features
- **Cloud Integration**: Uploads securely to Google Drive (or any `rclone` provider).
- **Matrix UI**: Retro-futuristic terminal interface with animated gauges and scrolling logs.
- **Smart Zipping**: Compresses folders individually with clean, relative paths.
- **Expert Ignores**: Exclude heavy folders like `node_modules` or `.git` with a checklist UI.
- **Scheduled Backups**: Built-in cron scheduler.

## Installation
1.  **Dependencies**:
    ```bash
    sudo apt install dialog zip rclone
    ```
2.  **Run**:
    ```bash
    chmod +x myBackUpTool.sh
    ./myBackUpTool.sh
    ```

## Configuration
1.  **Cloud Setup**: Go to **Settings > Setup Cloud Access** and follow the wizard to add your Google Drive (name it `gdrive`).
2.  **Select Remote**: Go to **Settings > Remote** and select `gdrive` from the list. You can specify a custom folder (default: `myBackUpTool_Data`).
3.  **Add Directories**: Go to **Dirs > Add** and browse to the folders you want to back up.

## Usage
- **Interactive**: Select **Backup** fro the main menu.
- **Automated**: Run `./myBackUpTool.sh --backup-all` (great for cron jobs).

## Themes
Change the look in **Settings > Theme**:
- Matrix (Green/Black)
- Retro (Amber/Black)
- Dracula (Purple/Dark)
- Oceanic (Cyan/Blue)
