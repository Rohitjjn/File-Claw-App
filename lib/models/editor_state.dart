import '../core/constants/app_constants.dart';
import 'file_type.dart';

/// Editor state cached per file. Stored under editor_cache/{id}.json.
class EditorState {
  final String fileId;
  final String content;
  final int cursorPosition;
  final int selectionStart;
  final int selectionEnd;
  final bool isModified;
  final DateTime lastSaved;
  final List<String> undoStack;
  final List<String> redoStack;
  final EditorMode mode;

  const EditorState({
    required this.fileId,
    required this.content,
    this.cursorPosition = 0,
    this.selectionStart = 0,
    this.selectionEnd = 0,
    this.isModified = false,
    required this.lastSaved,
    this.undoStack = const [],
    this.redoStack = const [],
    this.mode = EditorMode.preview,
  });

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;
  bool get canSave => isModified;

  EditorState copyWith({
    String? content,
    int? cursorPosition,
    int? selectionStart,
    int? selectionEnd,
    bool? isModified,
    DateTime? lastSaved,
    List<String>? undoStack,
    List<String>? redoStack,
    EditorMode? mode,
  }) {
    return EditorState(
      fileId: fileId,
      content: content ?? this.content,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      selectionStart: selectionStart ?? this.selectionStart,
      selectionEnd: selectionEnd ?? this.selectionEnd,
      isModified: isModified ?? this.isModified,
      lastSaved: lastSaved ?? this.lastSaved,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      mode: mode ?? this.mode,
    );
  }

  /// Push current snapshot to undo stack and clear redo stack.
  EditorState pushUndo(String previousContent) {
    final next = List<String>.from(undoStack)..add(previousContent);
    while (next.length > AppConstants.maxUndoStack) {
      next.removeAt(0);
    }
    return copyWith(undoStack: next, redoStack: const []);
  }

  Map<String, dynamic> toJson() => {
        'fileId': fileId,
        'content': content,
        'cursorPosition': cursorPosition,
        'selectionStart': selectionStart,
        'selectionEnd': selectionEnd,
        'isModified': isModified,
        'lastSaved': lastSaved.toIso8601String(),
        'undoStack': undoStack,
        'redoStack': redoStack,
        'mode': mode.name,
      };

  factory EditorState.fromJson(Map<String, dynamic> json) {
    return EditorState(
      fileId: json['fileId'] as String,
      content: json['content'] as String? ?? '',
      cursorPosition: (json['cursorPosition'] as num?)?.toInt() ?? 0,
      selectionStart: (json['selectionStart'] as num?)?.toInt() ?? 0,
      selectionEnd: (json['selectionEnd'] as num?)?.toInt() ?? 0,
      isModified: json['isModified'] as bool? ?? false,
      lastSaved: DateTime.tryParse(json['lastSaved'] as String? ?? '') ??
          DateTime.now(),
      undoStack:
          (json['undoStack'] as List?)?.map((e) => e.toString()).toList() ?? [],
      redoStack:
          (json['redoStack'] as List?)?.map((e) => e.toString()).toList() ?? [],
      mode: _parseMode(json['mode'] as String?),
    );
  }

  static EditorMode _parseMode(String? name) {
    if (name == null) return EditorMode.preview;
    for (final v in EditorMode.values) {
      if (v.name == name) return v;
    }
    return EditorMode.preview;
  }
}
