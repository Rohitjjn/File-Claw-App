/// Domain exceptions raised by Files Claw services.
///
/// These messages are user-facing — keep them friendly, no stack traces or
/// technical jargon. The original cause is logged via [logger] elsewhere.
class FileClawException implements Exception {
  final String message;
  final Object? cause;
  const FileClawException(this.message, {this.cause});

  @override
  String toString() => 'FileClawException: $message';
}

class FileNotFoundFailure extends FileClawException {
  const FileNotFoundFailure([String? path])
      : super('The file could not be found. It may have been moved or deleted.');
}

class PermissionDeniedFailure extends FileClawException {
  const PermissionDeniedFailure()
      : super('Permission denied. Please grant storage access in settings.');
}

class FileTooLargeFailure extends FileClawException {
  const FileTooLargeFailure()
      : super('This file is too large to edit. Opening in read-only preview.');
}

class UnsupportedEncodingFailure extends FileClawException {
  const UnsupportedEncodingFailure()
      : super('Could not decode this file. Try a different text encoding.');
}

class CorruptArchiveFailure extends FileClawException {
  const CorruptArchiveFailure()
      : super('The archive could not be read. It may be corrupted or unsupported.');
}

class PathTraversalFailure extends FileClawException {
  const PathTraversalFailure()
      : super('Refusing to open file: invalid path.');
}
