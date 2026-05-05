import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/editor_state.dart';
import '../../../../models/file_item.dart';
import '../../../../models/file_type.dart';
import '../../../../services/editor_cache_repository.dart';
import '../../../../services/file_reader_service.dart';

/// Manages text/code editor state for a single file: content, undo/redo,
/// modified flag and persistent draft cache.
class EditorController extends StateNotifier<EditorState> {
  EditorController(FileItem file, String initialContent, this._encoding)
      : _file = file,
        super(EditorState(
          fileId: file.id,
          content: initialContent,
          mode: EditorMode.edit,
          lastSaved: DateTime.now(),
        ));

  final FileItem _file;
  final String _encoding;
  String _baseContent = '';

  void setBaseContent(String content) {
    _baseContent = content;
  }

  void onTextChanged(String newContent) {
    if (newContent == state.content) return;
    final pushed = state.pushUndo(state.content);
    state = pushed.copyWith(
      content: newContent,
      isModified: newContent != _baseContent,
    );
  }

  void undo() {
    if (!state.canUndo) return;
    final undo = List<String>.from(state.undoStack);
    final previous = undo.removeLast();
    final redo = List<String>.from(state.redoStack)..add(state.content);
    state = state.copyWith(
      content: previous,
      undoStack: undo,
      redoStack: redo,
      isModified: previous != _baseContent,
    );
  }

  void redo() {
    if (!state.canRedo) return;
    final redo = List<String>.from(state.redoStack);
    final next = redo.removeLast();
    final undo = List<String>.from(state.undoStack)..add(state.content);
    state = state.copyWith(
      content: next,
      undoStack: undo,
      redoStack: redo,
      isModified: next != _baseContent,
    );
  }

  Future<void> save() async {
    await FileReaderService.instance
        .writeText(_file.path, state.content, encoding: _encoding);
    _baseContent = state.content;
    state = state.copyWith(
      isModified: false,
      lastSaved: DateTime.now(),
    );
    // Clear draft cache on successful save
    await EditorCacheRepository.instance.clear(_file.id);
  }

  Future<void> persistDraft() async {
    if (!state.isModified) return;
    await EditorCacheRepository.instance.save(state);
  }
}
