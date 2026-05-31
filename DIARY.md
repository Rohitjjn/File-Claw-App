# Developer Diary

## October 25, 2023 - Version 1.0.0+1 Updates

- **Added Permissions on Startup:** Updated `HomeScreen` to request storage permissions when the app first opens.
- **Added Pinch-to-Zoom for Previews:** Added `InteractiveViewer` wrapper to `TextPreview`, `MarkdownPreview`, and `CodePreview` so that users can zoom in and out of the text/code easily.
- **Enhanced Editor Toolbar:** Added Copy, Cut, Paste, and Select All buttons to the `EditorScreen` toolbar for better rich editing functionality.
- **Added Code Auto-formatting:** Added an auto-format button in the `EditorScreen` toolbar. This feature normalizes indentation (tabs/spaces) according to bracket/brace matching, making syntax editing easier.
- **HTML Browser Preview:** Added an option in `FilePreviewScreen`'s AppBar menu to "Preview in Browser" when opening an `.html` file.
- **Enabled Text Selection in Code Viewer:** Enclosed the `HighlightView` in `CodePreview` within a `SelectableRegion` to allow text selection and copying of code blocks.

## May 6, 2024 - v1.0.0+1
* **App Logo Update**: Replaced default Flutter icons with the new 'Files Claw' logo using `flutter_launcher_icons` and `flutter_native_splash` to fix overlapping white screen bug.
* **Editor Features**: Added `MarkdownTextController` to support live syntax styling for Markdown text while editing.
* **Quick Actions**: Implemented home screen shortcuts using `quick_actions` to allow users to quickly access settings, history, and the last opened file.
* **Floating Window**: Integrated `flutter_overlay_window` to provide a persistent floating preview of files alongside a persistent status bar notification.
* **Settings Fixes**: Removed non-functional storage permission trigger from the settings UI.
* **Zoom Fixes**: Corrected zoom behavior in `TextPreview`, `MarkdownPreview`, and `CodePreview` by disabling pan gestures in the `InteractiveViewer` wrapper to resolve conflicts with internal scroll views.

## May 29, 2024 - v1.0.0+1
* **Architecture Blueprint Generation**: Analyzed the entire codebase and generated a comprehensive `project-blueprint.md` file. This document details the tech stack (Flutter `^3.35.0`, Riverpod, no local DB yet), design system, app structure, platform configurations (Android only), and dependencies. It acts as a guide to understand how the app works behind the scenes without adding any non-existent features.

## May 30, 2024 - v1.0.0+1
* **UI Simplification & Performance**:
    - Simplified the sidebar by removing Settings, Theme, and About buttons, leaving only History and Version.
    - Added orange history icons to the Recent Files sections for better visual cues.
    - Fixed a UI hang by offloading JSON history parsing to a background thread using `compute`.
* **Feature Removal**:
    - Completely removed the Floating Window system (`flutter_overlay_window`) to streamline the app.
    - Repurposed the open notification to be a standard notification with the text: "Tap to open the file".

## 2024-05-30
### General Fixes & Enhancements
- Created proper vector icons (`icon_history.xml`, `icon_file.xml`, `icon_settings.xml`) in Android resources to be used by Quick Actions shortcuts.
- Addressed a hang issue when tapping the "Last Opened File" shortcut by adding error handling and initializing config in `lib/main.dart` before loading history.
- Restored the system status bar visibility by fixing the `SystemUiOverlayStyle` configuration in Flutter (`lib/core/themes/app_theme.dart`, `lib/main.dart`) and clearing `windowFullscreen` in Android XML styles to ensure it remains transparent and visible instead of a black bar.
- Repaired notifications when opening files by ensuring `hashCode.abs()` is used for positive integer notification IDs, and properly requesting notification permissions at startup for newer Android devices in `lib/services/notification_service.dart`.

- Added an ongoing, silent notification channel (`files_claw_ongoing`) in `AppNotificationService` that persists while a file is actively being previewed or edited. The notification is automatically canceled when the file screen is disposed.

### Performance & UI Updates
- Re-architected `TextPreview` and `CodePreview` to utilize `ListView.builder` for line-by-line rendering, solving performance jank when displaying large text/code files.
- Implemented `ZoomableView` encapsulating Flutter's built-in `InteractiveViewer` to bring pinch-to-zoom support across all text-based previews (Text, Code, Markdown), dynamically disabling pan at base scale to preserve natural scroll behavior.
- Fixed build error caused by missing import of `AppNotificationService` in EditorScreen.

### Feature Removal & Polish
- Uninstalled `flutter_local_notifications` and completely stripped `AppNotificationService` from the app architecture based on user instructions. Cleaned up the settings UI and model state to remove all notification toggles.
- Re-adjusted `ZoomableView` into a stateless wrapper around `InteractiveViewer` to ensure pinch-to-zoom gestures operate without jank and pan interruption.
- Addressed Android UI edge-to-edge issues by enforcing a transparent `navigationBarColor` and overriding `enforceNavigationBarContrast=false` in the native `styles.xml` definitions, ensuring no black bars are drawn by the system.
