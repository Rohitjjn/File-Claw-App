import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/file_item.dart';
import '../../../../services/history_repository.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// Holds the current file history list (most recent first).
class HistoryNotifier extends StateNotifier<List<FileItem>> {
  HistoryNotifier(this._ref) : super(const []) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final list = await HistoryRepository.instance.load();
    state = List.unmodifiable(list);
  }

  Future<void> refresh() => _load();

  Future<void> addOrPromote(FileItem item) async {
    final cfg = _ref.read(settingsProvider);
    await HistoryRepository.instance
        .upsert(item, historyLimit: cfg.historyLimit);
    await _load();
  }

  Future<void> remove(String fileId) async {
    await HistoryRepository.instance.remove(fileId);
    await _load();
  }

  Future<void> clear() async {
    await HistoryRepository.instance.clear();
    await _load();
  }

  Future<void> applyLimit(int limit) async {
    await HistoryRepository.instance.applyLimit(limit);
    await _load();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<FileItem>>((ref) {
  return HistoryNotifier(ref);
});
