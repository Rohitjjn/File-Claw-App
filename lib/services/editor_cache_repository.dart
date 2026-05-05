import 'dart:convert';
import 'dart:io';

import '../core/constants/app_constants.dart';
import '../models/editor_state.dart';
import 'storage_paths.dart';

/// Persists per-file editor drafts as JSON in editor_cache/.
class EditorCacheRepository {
  EditorCacheRepository._();
  static final EditorCacheRepository instance = EditorCacheRepository._();

  Future<EditorState?> load(String fileId) async {
    try {
      final file = await StoragePaths.instance.editorCacheFile(fileId);
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return null;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return EditorState.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(EditorState state) async {
    final file = await StoragePaths.instance.editorCacheFile(state.fileId);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(state.toJson()));
    if (await file.exists()) await file.delete();
    await tmp.rename(file.path);
  }

  Future<void> clear(String fileId) async {
    final file = await StoragePaths.instance.editorCacheFile(fileId);
    if (await file.exists()) await file.delete();
  }

  Future<void> clearAll() async {
    final dir = await StoragePaths.instance.editorCacheDir();
    if (!await dir.exists()) return;
    await for (final entry in dir.list()) {
      try {
        await entry.delete(recursive: true);
      } catch (_) {/* ignore */}
    }
  }

  /// Removes editor cache files older than [AppConstants.editorCacheRetentionDays].
  Future<void> pruneStale() async {
    final dir = await StoragePaths.instance.editorCacheDir();
    if (!await dir.exists()) return;
    final cutoff =
        DateTime.now().subtract(const Duration(days: AppConstants.editorCacheRetentionDays));
    await for (final entry in dir.list()) {
      try {
        if (entry is File) {
          final stat = await entry.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entry.delete();
          }
        }
      } catch (_) {/* ignore */}
    }
  }
}
