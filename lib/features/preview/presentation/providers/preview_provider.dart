import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../models/archive_node.dart';
import '../../../../models/file_item.dart';
import '../../../../models/file_type.dart';
import '../../../../services/archive_service.dart';
import '../../../../services/file_reader_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// Snapshot of preview content for a single file.
class PreviewData {
  final FileItem file;
  final String? text;
  final List<int>? bytes;
  final ArchiveNode? archiveRoot;
  final String? encodingUsed;
  final FileClawException? error;
  final bool truncated;

  const PreviewData({
    required this.file,
    this.text,
    this.bytes,
    this.archiveRoot,
    this.encodingUsed,
    this.error,
    this.truncated = false,
  });
}

/// Loads preview content for a file based on its detected [FileType].
final previewLoaderProvider =
    FutureProvider.family<PreviewData, FileItem>((ref, file) async {
  final cfg = ref.read(settingsProvider);
  try {
    if (!await File(file.path).exists()) {
      return PreviewData(file: file, error: const FileNotFoundFailure());
    }
    switch (file.type) {
      case FileType.image:
        final bytes = await FileReaderService.instance.readBytes(file.path);
        return PreviewData(file: file, bytes: bytes);
      case FileType.archive:
        final tree = await ArchiveService.instance.readTree(file.path);
        return PreviewData(file: file, archiveRoot: tree);
      case FileType.pdf:
      case FileType.docx:
        // Fallback: read bytes for now; we render as hex/info preview.
        final bytes = await FileReaderService.instance.readBytes(file.path);
        return PreviewData(file: file, bytes: bytes);
      case FileType.text:
      case FileType.markdown:
      case FileType.code:
      case FileType.spreadsheet:
      case FileType.unknown:
        final result = await FileReaderService.instance.readText(
          file.path,
          preferredEncoding:
              file.encoding ?? cfg.defaultEncoding,
        );
        return PreviewData(
          file: file,
          text: result.content,
          encodingUsed: result.encoding,
        );
    }
  } on FileClawException catch (e) {
    return PreviewData(file: file, error: e);
  } catch (_) {
    return PreviewData(
        file: file, error: const FileNotFoundFailure());
  }
});
