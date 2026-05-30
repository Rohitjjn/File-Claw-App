import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/app_config.dart';
import '../../../../models/file_type.dart';
import '../../../../services/config_repository.dart';

/// State notifier wrapping [AppConfig] persistence.
class SettingsNotifier extends StateNotifier<AppConfig> {
  SettingsNotifier() : super(const AppConfig()) {
    _load();
  }

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> _load() async {
    final cfg = await ConfigRepository.instance.load();
    state = cfg;
    _loaded = true;
  }

  Future<void> _persist(AppConfig next) async {
    state = next;
    await ConfigRepository.instance.save(next);
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      _persist(state.copyWith(themeMode: mode));

  Future<void> setFontScale(double scale) =>
      _persist(state.copyWith(fontScale: scale));

  Future<void> setHistoryLimit(int limit) =>
      _persist(state.copyWith(historyLimit: limit));

  Future<void> setShowLineNumbers(bool v) =>
      _persist(state.copyWith(showLineNumbers: v));

  Future<void> setWordWrap(bool v) =>
      _persist(state.copyWith(wordWrap: v));

  Future<void> setTabSize(int size) =>
      _persist(state.copyWith(tabSize: size));

  Future<void> setAutoSaveDrafts(bool v) =>
      _persist(state.copyWith(autoSaveDrafts: v));

  Future<void> setDefaultOpenMode(OpenMode mode) =>
      _persist(state.copyWith(defaultOpenMode: mode));

  Future<void> setDefaultEncoding(String enc) =>
      _persist(state.copyWith(defaultEncoding: enc));

  Future<void> setNotificationOnOpen(bool v) =>
      _persist(state.copyWith(notificationOnOpen: v));

  Future<void> setNotificationOnSave(bool v) =>
      _persist(state.copyWith(notificationOnSave: v));

  Future<void> setNotificationLowStorage(bool v) =>
      _persist(state.copyWith(notificationLowStorage: v));
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppConfig>((ref) {
  return SettingsNotifier();
});

/// Maps app theme mode to Flutter's [ThemeMode].
final themeModeProvider = Provider<ThemeMode>((ref) {
  final cfg = ref.watch(settingsProvider);
  switch (cfg.themeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});
