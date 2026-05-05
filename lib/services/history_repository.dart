import 'dart:convert';
import 'dart:io';

import '../core/constants/app_constants.dart';
import '../models/file_item.dart';
import 'storage_paths.dart';

/// Repository for the file history list.
///
/// Persists as a JSON array of [FileItem] entries, most-recent first.
/// Deduplicates by absolute path (re-opening a file moves it to the top
/// rather than creating a duplicate).
class HistoryRepository {
  HistoryRepository._();
  static final HistoryRepository instance = HistoryRepository._();

  List<FileItem>? _cached;

  Future<List<FileItem>> load() async {
    if (_cached != null) return List.unmodifiable(_cached!);
    try {
      final file = await StoragePaths.instance.historyFile();
      if (!await file.exists()) {
        _cached = [];
        return const [];
      }
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        _cached = [];
        return const [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _cached = [];
        return const [];
      }
      _cached = decoded
          .whereType<Map<String, dynamic>>()
          .map(FileItem.fromJson)
          .toList();
      return List.unmodifiable(_cached!);
    } catch (_) {
      _cached = [];
      return const [];
    }
  }

  Future<void> _persist() async {
    final file = await StoragePaths.instance.historyFile();
    final list = _cached ?? [];
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(encoded);
    if (await file.exists()) await file.delete();
    await tmp.rename(file.path);
  }

  /// Add or move a file to the top of history. Enforces [historyLimit].
  Future<void> upsert(FileItem item, {int historyLimit = AppConstants.defaultHistoryLimit}) async {
    await load();
    final list = List<FileItem>.from(_cached ?? []);
    final existingIdx = list.indexWhere((e) => e.path == item.path);
    final next = existingIdx >= 0
        ? list[existingIdx].copyWith(
            lastOpened: item.lastOpened,
            sizeInBytes: item.sizeInBytes,
            lastModified: item.lastModified,
            encoding: item.encoding,
          )
        : item;
    if (existingIdx >= 0) list.removeAt(existingIdx);
    list.insert(0, next);
    while (list.length > historyLimit.clamp(AppConstants.minHistoryLimit, AppConstants.maxHistoryLimit)) {
      list.removeLast();
    }
    _cached = list;
    await _persist();
  }

  Future<void> remove(String fileId) async {
    await load();
    final list = List<FileItem>.from(_cached ?? []);
    list.removeWhere((e) => e.id == fileId);
    _cached = list;
    await _persist();
  }

  Future<void> clear() async {
    _cached = [];
    await _persist();
  }

  /// Trim list to the new limit if it shrunk.
  Future<void> applyLimit(int historyLimit) async {
    await load();
    final list = List<FileItem>.from(_cached ?? []);
    final clamped = historyLimit.clamp(AppConstants.minHistoryLimit, AppConstants.maxHistoryLimit);
    while (list.length > clamped) {
      list.removeLast();
    }
    _cached = list;
    await _persist();
  }

  Future<FileItem?> findByPath(String path) async {
    final list = await load();
    for (final item in list) {
      if (item.path == path) return item;
    }
    return null;
  }
}
