# Risk Report

## 1. Complex Features
- **Archive Viewer**: Flutter uses the `archive` package which abstracts file extraction nicely. Android will require using `java.util.zip` or Apache Commons Compress. The UI for displaying a nested tree structure in Compose will be complex compared to the current Flutter implementation.
- **Code Highlighting/Editor**: Flutter relies on `flutter_highlight` and standard `TextField`. Implementing this in Compose requires custom `VisualTransformation` with regex parsing or webviews/third-party libraries like `Prettify` to ensure parity. Performance could be an issue for large files.
- **Zoomable Views**: `InteractiveViewer` in Flutter handles zooming natively. While Compose has zoom modifiers, achieving the exact same multi-touch nested scrolling/scaling behavior with text and code blocks requires careful state management.

## 2. Flutter-Specific Implementations
- **Riverpod**: The application makes heavy use of Riverpod, utilizing concepts like `ConsumerWidget` and `StateNotifier`. This will be fully replaced with ViewModels and `StateFlow` in Kotlin.
- **Platform Agnostic Paths**: `path_provider` abstracts file paths cleanly. Migration will require specific Android calls like `Context.filesDir` and potentially managing permissions explicitly based on the Android version (Scoped Storage).
- **JSON Serialization (Data Storage)**: `HistoryRepository` and `ConfigRepository` dump and read pure JSON using `dart:io`. In Kotlin, `DataStore` (Preferences or typed) or standard File I/O with `Gson`/`Moshi`/`Kotlinx Serialization` is needed. This might alter how "sync" operations feel.

## 3. Android-Specific Challenges
- **Permissions / Scoped Storage**: Android 10+ restricts arbitrary file access. Managing `MANAGE_EXTERNAL_STORAGE` or `ACTION_OPEN_DOCUMENT` properly to ensure the app can still index and preview files as the Flutter app did is a critical risk area. The flutter app seems to request `MANAGE_EXTERNAL_STORAGE` which is heavily scrutinized on the Play Store.
- **Quick Actions**: Jetpack Compose does not handle `Quick Actions` out of the box. We will need to map `ShortcutManager` intents to a Navigation Compose graph deep link.

## 4. Areas Requiring Manual Verification
- **Theme Parity**: Ensuring the exact colors and spacing match what the user experiences in Flutter.
- **App Startup / Splash**: Matching the splash screen transition to Home cleanly.
- **Scroll Performance**: Large text/code files rendering efficiently on mobile using Compose `LazyColumn` instead of generic scrolling. The memory mentions lazily rendering large files line-by-line; this pattern must be strictly replicated in Compose to prevent jank.
