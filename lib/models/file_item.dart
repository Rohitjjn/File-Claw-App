import '../core/utils/file_type_detector.dart';
import '../core/utils/size_formatter.dart';
import '../core/constants/app_constants.dart';
import 'file_type.dart';

/// Represents a file the user has opened in Files Claw.
///
/// Persisted in file_history.json. Identity is the absolute path so a file
/// re-opened later is recognised as the same item.
class FileItem {
  final String id;
  final String name;
  final String path;
  final String extension;
  final FileType type;
  final int sizeInBytes;
  final DateTime lastModified;
  final DateTime lastOpened;
  final bool isFavorite;
  final String? encoding;
  final int? scrollPosition;
  final EditorMode? lastEditorMode;

  const FileItem({
    required this.id,
    required this.name,
    required this.path,
    required this.extension,
    required this.type,
    required this.sizeInBytes,
    required this.lastModified,
    required this.lastOpened,
    this.isFavorite = false,
    this.encoding,
    this.scrollPosition,
    this.lastEditorMode,
  });

  factory FileItem.create({
    required String id,
    required String name,
    required String path,
    required int sizeInBytes,
    DateTime? lastModified,
    DateTime? lastOpened,
    String? encoding,
  }) {
    final ext = FileTypeDetector.extensionOf(name);
    final type = FileTypeDetector.detect(name);
    final now = DateTime.now();
    return FileItem(
      id: id,
      name: name,
      path: path,
      extension: ext,
      type: type,
      sizeInBytes: sizeInBytes,
      lastModified: lastModified ?? now,
      lastOpened: lastOpened ?? now,
      encoding: encoding,
    );
  }

  String get formattedSize => SizeFormatter.formatBytes(sizeInBytes);

  bool get isEditable =>
      AppConstants.editableExtensions.contains(extension) &&
      sizeInBytes <= AppConstants.maxFileSizeForEdit;

  bool get isPreviewable =>
      AppConstants.previewableExtensions.contains(extension) ||
      type == FileType.unknown;

  FileItem copyWith({
    String? name,
    String? path,
    int? sizeInBytes,
    DateTime? lastModified,
    DateTime? lastOpened,
    bool? isFavorite,
    String? encoding,
    int? scrollPosition,
    EditorMode? lastEditorMode,
  }) {
    return FileItem(
      id: id,
      name: name ?? this.name,
      path: path ?? this.path,
      extension: extension,
      type: type,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      lastModified: lastModified ?? this.lastModified,
      lastOpened: lastOpened ?? this.lastOpened,
      isFavorite: isFavorite ?? this.isFavorite,
      encoding: encoding ?? this.encoding,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      lastEditorMode: lastEditorMode ?? this.lastEditorMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'extension': extension,
        'type': type.name,
        'sizeInBytes': sizeInBytes,
        'lastModified': lastModified.toIso8601String(),
        'lastOpened': lastOpened.toIso8601String(),
        'isFavorite': isFavorite,
        'encoding': encoding,
        'scrollPosition': scrollPosition,
        'lastEditorMode': lastEditorMode?.name,
      };

  factory FileItem.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final ext = (json['extension'] as String?) ??
        FileTypeDetector.extensionOf(name);
    final type = _parseType(json['type'] as String?) ??
        FileTypeDetector.detect(name);
    return FileItem(
      id: json['id'] as String,
      name: name,
      path: json['path'] as String,
      extension: ext,
      type: type,
      sizeInBytes: (json['sizeInBytes'] as num?)?.toInt() ?? 0,
      lastModified: DateTime.tryParse(json['lastModified'] as String? ?? '') ??
          DateTime.now(),
      lastOpened: DateTime.tryParse(json['lastOpened'] as String? ?? '') ??
          DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      encoding: json['encoding'] as String?,
      scrollPosition: (json['scrollPosition'] as num?)?.toInt(),
      lastEditorMode: _parseMode(json['lastEditorMode'] as String?),
    );
  }

  static FileType? _parseType(String? name) {
    if (name == null) return null;
    for (final v in FileType.values) {
      if (v.name == name) return v;
    }
    return null;
  }

  static EditorMode? _parseMode(String? name) {
    if (name == null) return null;
    for (final v in EditorMode.values) {
      if (v.name == name) return v;
    }
    return null;
  }

  @override
  String toString() => 'FileItem($name, $path)';
}
