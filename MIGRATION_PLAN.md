# Migration Plan

## Phase 1: Deep Repository Analysis and Migration Foundation
**Status: In Progress**
- Complete repository audit (Screens, Routes, Navigation, Widgets, Services, etc.).
- Identify and prioritize core features.
- Create Target Compose Project Foundation.
- Dependency Analysis (`DEPENDENCY_MAPPING.md`).
- Feature Parity Checklist (`FEATURE_PARITY_CHECKLIST.md`).
- Risk Report (`RISK_REPORT.md`).
- Project Structure Plan (`PROJECT_STRUCTURE.md`).

## Phase 2: Theme + Design System
- Setup Compose `MaterialTheme` using extracted colors and typography from `ClaudeColors` and `AppTheme`.
- Implement common UI components (e.g., `ClaudeAppBar`, `ClaudeButton`, `ClaudeCard`, `ClaudeDialog`, `ClaudeListTile`, `EmptyState`, `SectionHeader`).
- Establish `Theme` switching (Dark/Light/System).

## Phase 3: Models + Data Layer
- Translate Dart models (`FileItem`, `AppConfig`, `ArchiveNode`, `EditorState`) to Kotlin Data Classes.
- Implement Local Storage (SharedPreferences / DataStore) for `ConfigRepository` and `HistoryRepository` replacements.
- Migrate utility classes (`FileTypeDetector`, `PathValidator`, `TimeFormat`, `SizeFormatter`).

## Phase 4: Navigation + App Shell
- Setup Jetpack Navigation Compose (`NavHost`, Routes).
- Implement Splash Screen.
- Implement generic layout scaffolds mimicking the Flutter behavior.
- Establish quick actions / intent handling.

## Phase 5: Primary Screens
- Implement `HomeScreen`.
- Implement `SidebarDrawer` (with Navigation integration).
- Implement `SearchScreen`.

## Phase 6: Secondary Screens
- Implement `SettingsScreen`.
- Implement `AboutScreen`.
- Implement `EditorScreen`.

## Phase 7: Logic + Services
- Connect UI to ViewModels.
- Implement File Picker logic.
- Implement `PreviewProvider` logic (Text, Image, Hex, Markdown, Code, Archive).
- Implement Markdown/Code highlight parsers for Jetpack Compose.
- File read/write logic.
- Quick actions handling with UI updating.

## Phase 8: Validation + Build + ZIP
- Run through `FEATURE_PARITY_CHECKLIST.md`.
- Ensure all Android configurations (`AndroidManifest.xml`, permissions, icon, app name) match Flutter app.
- Package output into `Native_Compose_Migration.zip`.
