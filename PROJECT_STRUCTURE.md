# Jetpack Compose Project Structure

The target application structure for the migrated Android project will adhere to Clean Architecture guidelines with MVVM, localized entirely within `jetpack_compose/`:

```
jetpack_compose/
├── app/
│   ├── build.gradle.kts
│   ├── src/
│   │   ├── main/
│   │   │   ├── AndroidManifest.xml
│   │   │   ├── java/com/filesclaw/
│   │   │   │   ├── MainActivity.kt
│   │   │   │   ├── FilesClawApplication.kt
│   │   │   │   ├── ui/
│   │   │   │   │   ├── theme/          (Color, Typography, Shape, Theme)
│   │   │   │   │   ├── components/     (Reusable composables e.g. ClaudeButton, ClaudeCard)
│   │   │   │   │   ├── screens/        (Home, Settings, Preview, Editor, Search, Splash)
│   │   │   │   ├── navigation/         (NavHost, NavGraph, Routes)
│   │   │   │   ├── domain/
│   │   │   │   │   ├── model/          (AppConfig, FileItem, ArchiveNode)
│   │   │   │   │   ├── repository/     (Interfaces for data sources)
│   │   │   │   │   ├── usecase/        (Business logic e.g., FormatFileSizeUseCase)
│   │   │   │   ├── data/
│   │   │   │   │   ├── local/          (DataStore, File system access)
│   │   │   │   │   ├── repository/     (Implementations of repositories)
│   │   │   │   ├── service/            (File picker, permissions, intent handlers)
│   │   │   │   ├── util/               (FileTypeDetector, formatters, extensions)
│   │   │   ├── res/
│   │   │   │   ├── drawable/           (Vector assets, legacy icons)
│   │   │   │   ├── values/             (strings.xml, themes.xml for app launch)
│   │   │   │   ├── mipmap-anydpi-v26/  (Launcher icons)
├── build.gradle.kts
├── settings.gradle.kts
└── gradle/
    └── wrapper/
```
