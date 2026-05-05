/// Centralised constants for Files Claw.
class AppConstants {
  AppConstants._();

  static const String appName = 'Files Claw';
  static const String appTagline = 'Preview Everything. Edit Anywhere.';
  static const String appVersion = '1.0.0';

  // Persistence
  static const String configFileName = 'app_config.json';
  static const String historyFileName = 'file_history.json';
  static const String floatingSessionFileName = 'floating_session.json';
  static const String editorCacheDir = 'editor_cache';
  static const String configDir = 'config';
  static const String historyDir = 'history';

  // Limits
  static const int maxHistoryLimit = 100;
  static const int defaultHistoryLimit = 20;
  static const int minHistoryLimit = 10;
  static const int maxUndoStack = 50;
  static const int maxFileSizeForEdit = 10 * 1024 * 1024; // 10 MB
  static const int maxArchiveInlinePreview = 1 * 1024 * 1024; // 1 MB
  static const int recentFilesOnHome = 5;
  static const int editorAutoSaveSeconds = 30;
  static const int editorCacheRetentionDays = 30;

  // Editable extensions (lowercase, no dot)
  static const List<String> editableExtensions = [
    'txt', 'md', 'markdown', 'json', 'xml', 'html', 'htm', 'xhtml',
    'css', 'scss', 'js', 'jsx', 'ts', 'tsx', 'py', 'java', 'kt',
    'cpp', 'cc', 'cxx', 'c', 'h', 'hpp', 'dart', 'go', 'rs',
    'log', 'xsl', 'yaml', 'yml', 'ini', 'conf', 'cfg', 'sh', 'bat',
    'env', 'gitignore', 'lock', 'toml', 'rb', 'php', 'swift',
  ];

  static const List<String> archiveExtensions = ['zip', 'tar', 'gz', 'tgz'];
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
  static const List<String> pdfExtensions = ['pdf'];
  static const List<String> docxExtensions = ['docx'];
  static const List<String> spreadsheetExtensions = ['csv'];

  static List<String> get previewableExtensions => [
        ...editableExtensions,
        ...archiveExtensions,
        ...imageExtensions,
        ...pdfExtensions,
        ...docxExtensions,
        ...spreadsheetExtensions,
      ];

  static const Map<String, String> syntaxLanguageMap = {
    'py': 'python',
    'java': 'java',
    'kt': 'kotlin',
    'js': 'javascript',
    'jsx': 'javascript',
    'ts': 'typescript',
    'tsx': 'typescript',
    'html': 'xml',
    'htm': 'xml',
    'xhtml': 'xml',
    'css': 'css',
    'scss': 'scss',
    'dart': 'dart',
    'cpp': 'cpp',
    'cc': 'cpp',
    'cxx': 'cpp',
    'c': 'cpp',
    'h': 'cpp',
    'hpp': 'cpp',
    'go': 'go',
    'rs': 'rust',
    'json': 'json',
    'xml': 'xml',
    'xsl': 'xml',
    'yaml': 'yaml',
    'yml': 'yaml',
    'md': 'markdown',
    'markdown': 'markdown',
    'sh': 'bash',
    'bat': 'dos',
    'rb': 'ruby',
    'php': 'php',
    'swift': 'swift',
    'ini': 'ini',
    'conf': 'ini',
    'cfg': 'ini',
    'toml': 'ini',
    'log': 'plaintext',
    'txt': 'plaintext',
  };
}
