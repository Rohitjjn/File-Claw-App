# Files Claw - Project Blueprint
## 1. System Architecture & Tech Stack
- **Flutter SDK Version**: `>=3.35.0` (from `pubspec.yaml`)
- **Dart SDK constraints**: `^3.9.2`
- **Routing System**: `MaterialApp.routes` / `onGenerateRoute` with custom `PageRouteBuilder` transitions (`_fadeRoute`, `_slideRoute`) (from `lib/main.dart`). `go_router` is in `pubspec.yaml` but not currently used in `main.dart`.
- **Build Tools & Bundlers**:
  - Android: `compileSdk = 35`, `minSdk = 26`, `targetSdk = 34` (from `android/app/build.gradle.kts`). Gradle KTS is used.
  - iOS: Not yet implemented — no `ios/` directory found.
  - Code generation: Not yet implemented — no `build_runner` or `.g.dart` files found.
  - Linting: `flutter_lints` enabled in `analysis_options.yaml`.

## 2. Deep Design System & UI/UX
Design system is centralized in `lib/core/themes/app_theme.dart` and `lib/core/themes/claude_colors.dart`.

### Color Palette (from `ClaudeColors`)
- `primary`: `Color(0xFFD97757)` (Terracotta orange)
- `primaryVariant`: `Color(0xFFB95C3D)`
- `lightBackground`: `Color(0xFFFAFAF8)`
- `lightSurface`: `Color(0xFFFFFFFF)`
- `lightSurfaceMuted`: `Color(0xFFF5F5F0)`
- `lightBorder`: `Color(0xFFE5E5E0)`
- `lightDivider`: `Color(0xFFE5E5E0)`
- `lightTextPrimary`: `Color(0xFF2D2D2D)`
- `lightTextSecondary`: `Color(0xFF6B6B6B)`
- `darkBackground`: `Color(0xFF1A1A1A)`
- `darkSurface`: `Color(0xFF2D2D2D)`
- `darkSurfaceMuted`: `Color(0xFF252525)`
- `darkBorder`: `Color(0xFF3D3D3D)`
- `darkDivider`: `Color(0xFF3D3D3D)`
- `darkTextPrimary`: `Color(0xFFE5E5E5)`
- `darkTextSecondary`: `Color(0xFF9CA3AF)`
- Semantic: `error: Color(0xFFEF4444)`, `success: Color(0xFF10B981)`, `warning: Color(0xFFF59E0B)`, `info: Color(0xFF3B82F6)`

### Typography
- Uses `GoogleFonts.interTextTheme` for general UI text.
- Uses `GoogleFonts.robotoMono` for code/editor surfaces.
- Weights used: `w500`, `w600` for titles/headlines.
- Sizes used: `titleLarge` (20), `titleMedium` (18), `bodyLarge` (16), `bodyMedium` (14), `bodySmall` (13).

### Recurring UI Patterns
- Card theme: `elevation: 0`, `BorderRadius.circular(16)`, 1px border.
- Dialog theme: `elevation: 0`, `BorderRadius.circular(20)`.
- Input fields: `filled: true`, `contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)`, `BorderRadius.circular(12)`.
- Buttons: `elevation: 0`, `BorderRadius.circular(12)`, `minimumSize: Size(0, 48)`, `padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14)`.
- Bottom Sheet: `BorderRadius.vertical(top: Radius.circular(24))`.

### UI Component Strategy
- Custom Widgets: Centralized in `lib/core/widgets/` (`claude_app_bar.dart`, `claude_button.dart`, `claude_card.dart`, `claude_dialog.dart`, `claude_list_tile.dart`, `empty_state.dart`, `file_icon.dart`, `section_header.dart`, `shimmer_loader.dart`).
- UI Libraries: `google_fonts`, `flutter_svg`, `shimmer`, `flutter_slidable`, `flutter_animate`, `photo_view`, `flutter_highlight`.

## 3. Data Flow & State Management
### Local State
- Uses `flutter_riverpod` (`^2.5.1`).
- Legacy `StateNotifier` is used instead of newer `Notifier`/`AsyncNotifier` (e.g., `SettingsNotifier extends StateNotifier<AppConfig>`, `HistoryNotifier extends StateNotifier<List<FileItem>>`, `EditorController extends StateNotifier<EditorState>`).
- Exposes state via `ConsumerWidget` and `ConsumerStatefulWidget`.

### Global State
- `ProviderScope` wraps the app in `main.dart`.
- User preferences and history managed via singletons (`ConfigRepository.instance`, `HistoryRepository.instance`).

### Data Fetching
- Local-only. File system interactions through `dart:io` and `path_provider`.
- `EditorCacheRepository` handles local caching of file edits.

## 4. Local Database & Storage Strategy
### Database Engine
- Not yet implemented — no SQLite, Hive, Isar, or Drift dependencies found.

### Schema & Migrations
- Not yet implemented.

### Data Access Pattern
- Repository pattern implemented via singleton classes reading/writing JSON files directly to local storage (`ConfigRepository`, `HistoryRepository`).

### Local Storage (Non-DB)
- Uses `dart:io` `File` with JSON encoding/decoding for persistence (e.g., `history.json`, `config.json`).
- `shared_preferences` is in `pubspec.yaml` but `grep` shows no usage in `lib/`.
- `path_provider` used via `StoragePaths` to get application directories.

## 5. File Structure & Mental Model
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── themes/
│   ├── utils/
│   └── widgets/
├── features/          (Feature-based vertical slicing)
│   ├── about/
│   ├── editor/
│   ├── history/
│   ├── home/
│   ├── preview/
│   ├── search/
│   ├── settings/
│   └── splash/
├── models/            (Data classes e.g., FileItem, AppConfig)
├── services/          (Repositories and core services e.g., ConfigRepository, StoragePaths)
└── main.dart          (Entry point, routing, providers setup)
```
- **Logical Separation**: Feature-first structure. Repositories/Services handle storage/OS interaction.
- **Dependency Injection**: Singleton pattern used (e.g., `ConfigRepository.instance`) instead of a DI package.

## 6. Coding Standards & Conventions
- **Dart**: Null-safety enabled (`^3.9.2`).
- **Linting**: Uses `flutter_lints` defaults (`analysis_options.yaml`).
- **File Naming**: Standard `snake_case.dart`.
- **Models**: Plain Dart classes with `fromJson`/`toJson` methods. No `freezed` or `json_serializable` used.
- **Error Handling**: Standard `try-catch` blocks returning default values or empty states on error (seen in `HistoryRepository`, `ConfigRepository`). Custom exception `FileClawException implements Exception`.
- **Async Patterns**: Heavy use of `async`/`await` for file I/O operations.

## 7. Platform-Specific Configuration
### Android
- `minSdk`: 26, `targetSdk`: 34, `compileSdk`: 35.
- `AndroidManifest.xml`: Requires external storage read/write permissions, `MANAGE_EXTERNAL_STORAGE` (ScopedStorage ignored), `SYSTEM_ALERT_WINDOW`, `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE`.
- Removed `flutter_overlay_window` system.

### iOS
- Not yet implemented — no `ios/` directory found.

## 8. Strict Deployment & Architecture Constraints
> ⚠️ **MANDATORY WARNING FOR FUTURE AI AGENTS:**
>
> **DEPLOYMENT TARGET: MOBILE STORES (Play Store / App Store)**
> - This is a **LOCAL-ONLY** application. No external backend dependencies.
> - **NO network calls** should be introduced without explicit architectural review.
> - **NO Supabase, Firebase, or HTTP client packages** should be added unless explicitly requested.
> - Database must remain strictly local. Any sync feature requires a separate PRD and architecture review.
> - Respect platform storage constraints: iOS App Groups, Android Scoped Storage.
> - Keep isolate/background thread usage minimal and documented.
> - Binary size matters: Avoid heavy dependencies. Document every new package addition.

## 9. Dependencies Audit
Key packages from `pubspec.yaml`:
- `flutter_riverpod: ^2.5.1` (State)
- `path_provider: ^2.1.4` (Paths)
- `shared_preferences: 2.5.3` (Unused)
- `google_fonts: ^6.2.1` (Typography)
- `flutter_markdown: ^0.7.3+1`, `flutter_highlight: ^0.7.0` (Preview/Editor)
- `flutter_local_notifications: ^17.2.3` (Notifications)
- `go_router: ^14.2.7` (Unused)
- `quick_actions: ^1.1.0` (Shortcuts)
- `file_picker: ^8.1.2`, `open_filex: ^4.5.0`, `mime: ^1.0.6` (File handling)
- `permission_handler: ^11.3.1`, `device_info_plus: ^10.1.2`, `share_plus: ^10.0.2` (Device & Permissions)

## 10. Reverse Engineering Checklist
- [x] `pubspec.yaml`
- [x] `analysis_options.yaml`
- [x] `lib/main.dart`
- [x] Repositories (`HistoryRepository`, `ConfigRepository`)
- [x] Android directory (`build.gradle.kts`, `AndroidManifest.xml`)
