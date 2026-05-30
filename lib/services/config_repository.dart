import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../models/app_config.dart';
import 'storage_paths.dart';

/// Reads and writes the singleton [AppConfig] JSON.
class ConfigRepository {
  ConfigRepository._();
  static final ConfigRepository instance = ConfigRepository._();

  AppConfig? _cached;

  Future<AppConfig> load() async {
    if (_cached != null) return _cached!;
    try {
      final file = await StoragePaths.instance.configFile();
      if (!await file.exists()) {
        _cached = const AppConfig();
        await save(_cached!);
        return _cached!;
      }
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        _cached = const AppConfig();
        return _cached!;
      }
      final decoded = await compute(jsonDecode, raw) as Map<String, dynamic>;
      _cached = AppConfig.fromJson(decoded);
      return _cached!;
    } catch (_) {
      // Corrupt config: reset to defaults rather than crashing the app.
      _cached = const AppConfig();
      return _cached!;
    }
  }

  Future<void> save(AppConfig config) async {
    _cached = config;
    final file = await StoragePaths.instance.configFile();
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(config.toJson()));
    if (await file.exists()) await file.delete();
    await tmp.rename(file.path);
  }

  AppConfig? get cached => _cached;
}
