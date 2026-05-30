# Changelog - Files Claw

All notable changes to this project will be documented in this file.

## [Unreleased] - 2024-05-30
### Added
- Orange `Icons.history` added to "Recent Files" section headers for improved visual consistency.

### Changed
- Simplified Sidebar Drawer: Removed "Settings", "Theme", and "About" buttons. Now only displays history and app version.
- Updated file-open notification message to "Tap to open the file" and made it a standard transient notification.
- Optimized file history loading using Flutter's `compute` function to prevent UI thread hanging.

### Removed
- **Floating Window System:** Completely removed the `flutter_overlay_window` dependency and all related code/settings.

## [1.0.0+1] - 2024-05-29
- Initial release documentation and architecture blueprint.

### Fixed
- Fixed quick actions shortcut icons not displaying (added vector drawables).
- Fixed quick actions "Last Opened File" causing the app to hang (added exception handling and config pre-warming).
- Fixed system status bar rendering as black by explicitly removing full-screen mode from Android styles and applying proper `SystemUiOverlayStyle`.
- Fixed file opening notifications failing due to invalid negative notification IDs and missing Android 13 runtime notification permissions.

### Added
- Added a silent, ongoing notification while a file is open in the app that cannot be dismissed by the user and is cleared when the file is closed. Tapping the notification brings the file to the foreground.
