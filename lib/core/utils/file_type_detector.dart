import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';
import '../../models/file_type.dart';

/// Detects logical file type from filename / extension.
///
/// This is best-effort and based on extension. Final preview rendering
/// also reads bytes to confirm (e.g., text vs binary heuristics).
class FileTypeDetector {
  FileTypeDetector._();

  /// Returns lowercase extension without leading dot. Empty string if none.
  static String extensionOf(String pathOrName) {
    final ext = p.extension(pathOrName);
    if (ext.isEmpty) return '';
    return ext.substring(1).toLowerCase();
  }

  static FileType detect(String pathOrName) {
    final ext = extensionOf(pathOrName);
    if (ext.isEmpty) return FileType.unknown;
    if (AppConstants.imageExtensions.contains(ext)) return FileType.image;
    if (AppConstants.pdfExtensions.contains(ext)) return FileType.pdf;
    if (AppConstants.docxExtensions.contains(ext)) return FileType.docx;
    if (AppConstants.archiveExtensions.contains(ext)) return FileType.archive;
    if (AppConstants.spreadsheetExtensions.contains(ext)) {
      return FileType.spreadsheet;
    }
    if (ext == 'md' || ext == 'markdown') return FileType.markdown;
    if (AppConstants.editableExtensions.contains(ext)) {
      // Distinguish plain text vs code by syntax map.
      if (ext == 'txt' || ext == 'log') return FileType.text;
      if (AppConstants.syntaxLanguageMap.containsKey(ext)) return FileType.code;
      return FileType.text;
    }
    return FileType.unknown;
  }

  static bool isEditable(String pathOrName) {
    return AppConstants.editableExtensions.contains(extensionOf(pathOrName));
  }

  static bool isPreviewable(String pathOrName) {
    return AppConstants.previewableExtensions.contains(extensionOf(pathOrName));
  }

  static String? syntaxLanguageFor(String pathOrName) {
    final ext = extensionOf(pathOrName);
    return AppConstants.syntaxLanguageMap[ext];
  }
}
