# Files Claw App Architecture

Files Claw is a Flutter application designed for offline file previewing and editing, styled with a clean, Claude-like interface.

## 1. Project Structure

The application adopts a feature-based folder structure combined with clean architecture concepts. The main source code is located in the `lib/` directory.

```
lib/
├── core/         # Shared resources across the app
│   ├── constants/
│   ├── errors/
│   ├── themes/   # App styling, ClaudeColors, AppTheme
│   ├── utils/    # Utility functions (e.g., file type detection)
│   └── widgets/  # Reusable UI components (ClaudeAppBar, ClaudeCard, etc.)
├── features/     # Feature modules encapsulating UI and state
│   ├── about/
│   ├── editor/   # Code/text editing functionality
│   ├── history/  # File viewing history
│   ├── home/     # Main landing screen
│   ├── notifications/
│   ├── preview/  # Multi-format file viewing
│   ├── search/   # File search
│   ├── settings/ # App configuration
│   ├── sidebar/  # Navigation drawer
│   └── splash/   # Splash screen
├── models/       # Data entities (FileItem, FileType, EditorState)
├── services/     # External integrations and local repositories
│   └── (StoragePaths, FilePickerService, ConfigRepository, etc.)
└── main.dart     # Entry point, dependency injection, and routing
```

## 2. Technical Stack & Key Libraries

- **Framework**: Flutter (SDK >= 3.35.0)
- **State Management**: `flutter_riverpod` - Used extensively for dependency injection and reactive state management across features.
- **Routing**: Native Flutter `Navigator` with custom `PageRouteBuilder` animations (fade and slide transitions defined in `main.dart`).
- **Local Storage / Persistence**:
  - `path_provider` and `shared_preferences` for accessing local paths and basic settings.
  - Custom `StoragePaths` service resolving to application document directories (keeping files hidden from public storage).
  - Data stored in JSON files (`config.json`, `history.json`, cache files).
- **File System Handling**:
  - `file_picker` to select files from the device.
  - `open_filex` to delegate opening files to native apps when needed.
  - `mime` for MIME type detection.
- **UI and Styling**:
  - `google_fonts` for typography.
  - `flutter_svg`, `flutter_animate`, `flutter_staggered_animations` for dynamic and smooth interfaces.
  - Custom theming using `ClaudeColors` for light/dark modes.
- **File Previews**:
  - `flutter_markdown` for `.md` files.
  - `photo_view` for images.
  - `flutter_highlight` for syntax highlighting in code files.
  - `archive` for exploring ZIP/TAR files.
  - `csv` for tabular data.

## 3. Core Concepts and Models

### `FileItem`
The central domain model representing a file within the app.
- Contains metadata: `id`, `name`, `path`, `extension`, `sizeInBytes`, `lastModified`, `lastOpened`.
- Determines capabilities via `isEditable` and `isPreviewable` getters based on file extension and size constraints defined in `AppConstants`.

### Repositories and Services
- **`StoragePaths`**: Manages the directory structure within the app's sandboxed storage.
- **`HistoryRepository`**: Handles reading/writing the recently opened files list.
- **`EditorCacheRepository`**: Manages temporary cache/drafts for files being edited.
- **`ConfigRepository`**: Loads and saves user preferences.
- **`FileReaderService`**: Abstraction for safely reading file contents.
- **`ArchiveService`**: Logic for extracting and generating tree views for archive formats.

## 4. Key Features & Workflows

1. **Home & History**:
   - The user lands on the `HomeScreen` which displays recent files from the `historyProvider`.
   - Users can tap a floating action button to pick a new file via `FilePickerService`.
2. **File Preview**:
   - Selecting a file navigates to `/preview` (`FilePreviewScreen`).
   - The screen dynamically chooses the correct viewer widget (Text, Image, Markdown, Archive Tree, etc.) based on the `FileItem.type`.
3. **File Editing**:
   - If a file is text/code and under the size limit, the user can switch to the `/editor` (`EditorScreen`).
   - The editor manages syntax highlighting and unsaved changes via the `EditorCacheRepository`.
4. **Settings & Themes**:
   - Controlled by `SettingsScreen` and `settings_provider.dart`, allowing toggling between light and dark modes, which updates the root `MaterialApp` reactively.
