import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../core/constants/app_constants.dart';
import '../core/errors/exceptions.dart';
import '../core/utils/path_validator.dart';

/// Reads files from disk with encoding detection and size guards.
class FileReaderService {
  FileReaderService._();
  static final FileReaderService instance = FileReaderService._();

  /// Read a text file as UTF-8, falling back to Latin-1 on decode failure.
  /// Returns the decoded string and the encoding actually used.
  Future<({String content, String encoding})> readText(String path,
      {String? preferredEncoding}) async {
    final safe = PathValidator.validateOrThrow(path);
    final file = File(safe);
    if (!await file.exists()) throw const FileNotFoundFailure();
    try {
      final bytes = await file.readAsBytes();
      final encoding = preferredEncoding ?? 'utf-8';
      try {
        if (encoding == 'utf-8') {
          return (content: utf8.decode(bytes, allowMalformed: false), encoding: 'utf-8');
        }
        if (encoding == 'ascii') {
          return (content: ascii.decode(bytes, allowInvalid: false), encoding: 'ascii');
        }
        if (encoding == 'iso-8859-1' || encoding == 'latin1') {
          return (content: latin1.decode(bytes), encoding: 'iso-8859-1');
        }
        if (encoding == 'utf-16') {
          // Best-effort UTF-16 decode using little-endian fallback.
          final str = String.fromCharCodes(_decodeUtf16(bytes));
          return (content: str, encoding: 'utf-16');
        }
        return (content: utf8.decode(bytes, allowMalformed: true), encoding: 'utf-8');
      } on FormatException {
        // Fall back to latin1 (always succeeds).
        return (content: latin1.decode(bytes), encoding: 'iso-8859-1');
      }
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == 13) {
        throw const PermissionDeniedFailure();
      }
      throw const FileNotFoundFailure();
    }
  }

  /// Read raw bytes (for images, archives, hex preview).
  Future<List<int>> readBytes(String path) async {
    final safe = PathValidator.validateOrThrow(path);
    final file = File(safe);
    if (!await file.exists()) throw const FileNotFoundFailure();
    return file.readAsBytes();
  }

  Future<int> sizeOf(String path) async {
    final safe = PathValidator.validateOrThrow(path);
    final file = File(safe);
    if (!await file.exists()) throw const FileNotFoundFailure();
    return file.length();
  }

  Future<DateTime> modifiedOf(String path) async {
    final safe = PathValidator.validateOrThrow(path);
    final file = File(safe);
    if (!await file.exists()) throw const FileNotFoundFailure();
    final stat = await file.stat();
    return stat.modified;
  }

  /// Save text back to disk with the chosen encoding.
  Future<void> writeText(String path, String content,
      {String encoding = 'utf-8'}) async {
    final safe = PathValidator.validateOrThrow(path);
    final file = File(safe);
    final parent = file.parent;
    if (!await parent.exists()) await parent.create(recursive: true);
    final List<int> bytes;
    switch (encoding) {
      case 'ascii':
        bytes = ascii.encode(content);
        break;
      case 'iso-8859-1':
      case 'latin1':
        bytes = latin1.encode(content);
        break;
      case 'utf-16':
        bytes = _encodeUtf16(content);
        break;
      case 'utf-8':
      default:
        bytes = utf8.encode(content);
    }
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    if (await file.exists()) await file.delete();
    await tmp.rename(file.path);
  }

  bool isEditableSize(int sizeInBytes) =>
      sizeInBytes <= AppConstants.maxFileSizeForEdit;

  // ------------------- private helpers -------------------

  List<int> _decodeUtf16(List<int> bytes) {
    if (bytes.length < 2) return const [];
    // Detect BOM
    bool littleEndian = true;
    int start = 0;
    if (bytes[0] == 0xFF && bytes[1] == 0xFE) {
      littleEndian = true;
      start = 2;
    } else if (bytes[0] == 0xFE && bytes[1] == 0xFF) {
      littleEndian = false;
      start = 2;
    }
    final result = <int>[];
    for (var i = start; i + 1 < bytes.length; i += 2) {
      final code = littleEndian
          ? (bytes[i] | (bytes[i + 1] << 8))
          : ((bytes[i] << 8) | bytes[i + 1]);
      result.add(code);
    }
    return result;
  }

  List<int> _encodeUtf16(String content) {
    final result = <int>[0xFF, 0xFE]; // little-endian BOM
    for (final code in content.codeUnits) {
      result.add(code & 0xFF);
      result.add((code >> 8) & 0xFF);
    }
    return result;
  }
}
