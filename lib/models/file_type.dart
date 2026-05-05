/// Logical type of a file Files Claw can interact with.
enum FileType {
  text,
  markdown,
  code,
  pdf,
  docx,
  archive,
  image,
  spreadsheet,
  unknown,
}

extension FileTypeX on FileType {
  String get label {
    switch (this) {
      case FileType.text:
        return 'Text';
      case FileType.markdown:
        return 'Markdown';
      case FileType.code:
        return 'Code';
      case FileType.pdf:
        return 'PDF';
      case FileType.docx:
        return 'Document';
      case FileType.archive:
        return 'Archive';
      case FileType.image:
        return 'Image';
      case FileType.spreadsheet:
        return 'Spreadsheet';
      case FileType.unknown:
        return 'File';
    }
  }
}

/// Editor surface mode.
enum EditorMode { preview, edit, split }

/// Default behaviour when opening a file.
enum OpenMode { preview, edit }

/// In-app theme preference.
enum AppThemeMode { light, dark, system }

/// Notification categories.
enum NotificationKind { fileOpened, fileSaved, floatingActive, lowStorage }
