# Changelog

## [v1.2.0] - 2026-01-19
### Added
- **Animated Progress Bar**: Visual gauge showing step-by-step progress (Compressing -> Uploading -> Cleaning).
- **Remote Folder Config**: Users can now specify a custom destination folder on their cloud drive.
- **Relative Zipping**: Zip files now contain only the target folder, not the full system path.

### Changed
- **Zip Naming**: Added seconds to timestamps for precision.
- **Backup Logic**: Improved error handling and automated mode stability.

## [v1.1.1] - 2026-01-19
- **Remote Selector**: Auto-detects `rclone` remotes to prevent configuration errors.

## [v1.1.0] - 2026-01-19
- **Cloud Setup**: Integrated `rclone config` wizard into Settings.

## [v1.0.9] - 2026-01-19
- **Directory Browser**: Added `dialog --dselect` for easier folder navigation.
- **Timestamps**: Added seconds to backup filenames.

## [v1.0.8] - 2026-01-19
- **Themes**: Added Retro, Dracula, and Oceanic themes.
- **UI**: Major overhaul of progress display.
