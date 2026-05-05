import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../core/errors/exceptions.dart';
import '../core/utils/path_validator.dart';
import '../models/file_item.dart';

/// Wraps file_picker to return a [FileItem] ready for opening.
class FilePickerService {
  FilePickerService._();
  static final FilePickerService instance = FilePickerService._();

  static const _uuid = Uuid();

  /// Show the system picker. Returns null if the user cancelled.
  Future<FileItem?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: false,
      withReadStream: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.first;
    final path = picked.path;
    if (path == null) {
      throw const FileNotFoundFailure();
    }
    return _toFileItem(path);
  }

  Future<List<FileItem>> pickMultipleFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
      withData: false,
      withReadStream: false,
    );
    if (result == null) return const [];
    final items = <FileItem>[];
    for (final picked in result.files) {
      final path = picked.path;
      if (path == null) continue;
      try {
        items.add(await _toFileItem(path));
      } catch (_) {
        // skip invalid files but keep the rest
      }
    }
    return items;
  }

  Future<FileItem> _toFileItem(String rawPath) async {
    final safe = PathValidator.validateOrThrow(rawPath);
    final file = File(safe);
    if (!await file.exists()) throw const FileNotFoundFailure();
    final stat = await file.stat();
    return FileItem.create(
      id: _uuid.v4(),
      name: p.basename(safe),
      path: safe,
      sizeInBytes: stat.size,
      lastModified: stat.modified,
      lastOpened: DateTime.now(),
    );
  }
}
