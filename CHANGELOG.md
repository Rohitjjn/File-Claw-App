# Changelog

All notable changes to this Flutter project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project scaffolding with Flutter SDK.
- Local database integration (SQLite/Hive/Isar — specify engine).
- Core navigation structure using [GoRouter/Navigator/AutoRoute].
- Base theme configuration with Material Design 3.
- Platform-specific permissions (Android/iOS).

### Changed
- Not yet implemented.

### Deprecated
- Not yet implemented.

### Removed
- Not yet implemented.

### Fixed
- Not yet implemented.

### Security
- Not yet implemented.

---

## [0.1.0] - YYYY-MM-DD

### Added
- Feature: [Feature Name] — [Brief description].
- Local DB schema version 1: [Tables/Collections created].
- State management setup: [Riverpod/Bloc/Provider/etc.].

### Fixed
- Initial bug fixes and platform-specific adjustments.

---

## Template for Future Entries

## [X.Y.Z] - YYYY-MM-DD

### Added
- New feature or capability.

### Changed
- Updates to existing functionality.

### Fixed
- Bug fixes.

### Platform Specific
- Android: [Changes specific to Android].
- iOS: [Changes specific to iOS].

### Database
- Schema migration from v[X] to v[Y].
- New table/collection: [Name].
- Index added: [Field name].

### Dependencies
- Added: `package_name: ^version`
- Updated: `package_name` from `^old` to `^new`
- Removed: `package_name`

## [Unreleased]

### Removed
- `2024-05-29` — Removed floating window system and related permissions (`SYSTEM_ALERT_WINDOW`) and dependencies (`flutter_overlay_window`).

### Changed
- `2024-05-29` — Updated notification behavior when opening a file to say "Tap to open the file." instead of "Tap to open the floating preview."
- `2024-05-29` — Removed Theme, Settings, and About options from the sidebar drawer, leaving only History.
- `2024-05-29` — Added custom icons for quick actions (Home screen App widgets).

### Fixed
- `2024-05-29` — Fixed "Last Opened File" quick action hanging issue by updating navigation logic.
