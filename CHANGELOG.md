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

### Fixed
- Fixed UI lag and freezing when opening large Text and Code files by switching preview rendering to a lazy line-by-line `ListView` approach instead of rendering the entire content at once.
- Added pinch-to-zoom support for Text, Code, and Markdown previews using a custom InteractiveViewer wrapper (`ZoomableView`).

### Fixed
- Fixed build error caused by missing import of `AppNotificationService` in EditorScreen.

### Changed
- Completely removed the notification system (`flutter_local_notifications`), including all associated settings toggles, as per user request.
- Improved the smooth pinch-to-zoom experience for Text, Code, and Markdown previews by simplifying the `ZoomableView` implementation.
- Fixed the bottom navigation bar appearing black on app startup by explicitly disabling `enforceNavigationBarContrast` and setting the color to transparent in Android's `styles.xml`.
