# Files Claw App Analysis

Files Claw is a Flutter application for offline file previewing and editing, styled with a Claude-like interface.

## 1. Project Structure and Architecture

The app uses a feature-based folder structure under `lib/`, combining clean architecture principles with Riverpod for state management.

```
lib/
├── core/         # Shared constants, themes, utilities, and widgets
├── features/     # Feature-based modules (home, editor, preview, etc.)
├── models/       # Data models (FileItem, FileType, EditorState)
├── services/     # Repositories and external services (storage, permissions)
└── main.dart     # Entry point, routing, and initialization
```

### Key Libraries:
- **State Management**: `flutter_riverpod`
- **Routing**: Native Flutter routing (`Navigator`, `PageRouteBuilder`) in `main.dart`, though `go_router` is in `pubspec.yaml`, it seems native routing is currently used.
- **Storage/Persistence**: `shared_preferences`, `path_provider`, saving JSON files locally via `StoragePaths`.
- **UI/Theming**: `google_fonts`, `flutter_svg`, `flutter_animate`, etc.
- **File Handling**: `file_picker`, `open_filex`, `mime`, `archive`
- **Preview**: `flutter_markdown`, `photo_view`, `flutter_highlight`, `csv`

## 2. Core Components

### Models
- `FileItem` (`lib/models/file_item.dart`): The central data structure representing a file. Stores metadata (path, size, extension, type, timestamps) and editor state (scroll position, encoding).
- `FileType` (`lib/models/file_type.dart`): Enum for categorized file types (image, text, code, archive, etc.).
- `EditorState`: Manages the state for text editing features.

### Services (Repositories)
- `StoragePaths`: Resolves local app directories for JSON persistence (config, history, cache).
- `HistoryRepository`: Manages the recent files history list.
- `EditorCacheRepository`: Handles caching unsaved editor state or drafts.
- `ConfigRepository`: App settings and configuration.
- `FilePickerService`: Interface for picking files from the device.
- `FileReaderService`: Reading content from files.
- `ArchiveService`: Extracting and parsing ZIP/archive files.

## 3. Key Features

### Routing & Navigation
Defined in `main.dart` with custom transition animations:
- `/` -> `SplashScreen`
- `/home` -> `HomeScreen`
- `/settings` -> `SettingsScreen`
- `/about` -> `AboutScreen`
- `/search` -> `SearchScreen`
- `/preview` -> `FilePreviewScreen` (Takes `FileItem` as argument)
- `/editor` -> `EditorScreen` (Takes `FileItem` as argument)

### Home Screen (`HomeScreen`)
- Displays recent file history using `HistoryProvider`.
- Contains an empty state with a call to action or a list of recent files.
- Features a sidebar drawer (`SidebarDrawer`).
- Allows picking a new file (`FilePickerService`), adding it to history, and opening it in preview.

### File Preview & Editing
- **Preview**: Handles displaying different types of files based on `FileTypeDetector`. Support for text (highlighting), markdown, images, archives (tree view), and CSVs.
- **Editor**: Handles text editing for valid text/code files up to a certain size limit (`AppConstants.maxFileSizeForEdit`).

## 4. UI/UX Design (Claude-styled)
- Follows a specific theme, indicated by classes like `ClaudeAppBar`, `ClaudeCard`, `ClaudeColors`.
- Uses staggered animations and modern transition effects to provide a smooth user experience.
- Supports both Light and Dark modes.
