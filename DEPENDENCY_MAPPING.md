# Dependency Mapping

| Flutter Package | Purpose | Compose Replacement | Migration Difficulty | Risk Level |
|---|---|---|---|---|
| `flutter_riverpod` | State Management | `ViewModel` + `StateFlow` + Hilt | Medium | Low |
| `path_provider` | Storage Paths | `Context.filesDir`, `Context.cacheDir`, `Environment.getExternalStorageDirectory()` | Low | Low |
| `shared_preferences` | Key-Value Storage | `DataStore` (Preferences) | Low | Low |
| `google_fonts` | Typography | `Downloadable Fonts` / `res/font` | Low | Low |
| `flutter_svg` | Vector Graphics | `VectorDrawable` / Jetpack Compose `Icon` | Medium | Low |
| `shimmer` | Loading Animations | Compose `Modifier.shimmer()` / custom Modifier | Medium | Low |
| `flutter_slidable` | Swipe Actions | Compose `SwipeToDismissBox` | Medium | Medium |
| `flutter_staggered_animations` | List Animations | Compose `AnimatedVisibility` / `animateItemPlacement` | Medium | Low |
| `flutter_animate` | View Animations | Compose Animation APIs (`animate*AsState`) | Medium | Low |
| `file_picker` | File Selection | `ActivityResultContracts.GetContent()` / `OpenDocument` | Medium | Low |
| `open_filex` | Opening Files externally | `Intent.ACTION_VIEW` with `FileProvider` | Medium | Medium |
| `mime` | MIME Type Detection | `MimeTypeMap` | Low | Low |
| `permission_handler` | Runtime Permissions | `ActivityResultContracts.RequestPermission` | Medium | Medium |
| `device_info_plus` | Device Information | `android.os.Build` | Low | Low |
| `share_plus` | Sharing Files | `Intent.ACTION_SEND` with `FileProvider` | Medium | Low |
| `flutter_markdown` | Markdown Preview | Markwon / Compose Markdown renderer | High | High |
| `photo_view` | Zoomable Images | Coil + Compose Zoom Modifier / Telephoto | Medium | Medium |
| `archive` | ZIP / Archive extraction | `java.util.zip` / Apache Commons Compress | High | High |
| `flutter_highlight` | Syntax Highlighting | Prettify / HighlightJs WebView / Custom Compose Parser | High | High |
| `csv` | CSV Parsing | Apache Commons CSV / Kotlinx Serialization CSV | Low | Low |
| `flutter_local_notifications` | Local Notifications | `NotificationManagerCompat` | Low | Low |
| `go_router` | App Navigation | Jetpack Navigation Compose | Medium | Low |
| `intl` | Internationalization/Dates | `java.time` / `SimpleDateFormat` | Low | Low |
| `url_launcher` | Opening URLs | `Intent.ACTION_VIEW` | Low | Low |
| `package_info_plus` | App Info | `PackageManager` | Low | Low |
| `uuid` | UUID Generation | `java.util.UUID` | Low | Low |
| `quick_actions` | App Shortcuts | `ShortcutManager` / Dynamic Shortcuts | Medium | Low |
