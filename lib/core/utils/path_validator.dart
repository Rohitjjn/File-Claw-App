import 'package:path/path.dart' as p;
import '../errors/exceptions.dart';

/// Validates incoming file paths to prevent traversal-style attacks.
///
/// Files Claw operates on user-selected files via SAF / file_picker, so the
/// surface for traversal abuse is small, but we still:
///   - reject relative '..' segments,
///   - reject embedded null bytes,
///   - reject overly long names,
///   - normalise the path to its canonical form.
class PathValidator {
  PathValidator._();

  /// Returns a normalised absolute path or throws [PathTraversalFailure].
  static String validateOrThrow(String rawPath) {
    if (rawPath.isEmpty) {
      throw const PathTraversalFailure();
    }
    if (rawPath.contains('\u0000')) {
      throw const PathTraversalFailure();
    }
    final normalised = p.normalize(rawPath);
    final segments = p.split(normalised);
    if (segments.contains('..')) {
      throw const PathTraversalFailure();
    }
    final fileName = p.basename(normalised);
    if (fileName.length > 255) {
      throw const PathTraversalFailure();
    }
    return normalised;
  }

  static bool isSafe(String rawPath) {
    try {
      validateOrThrow(rawPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}
