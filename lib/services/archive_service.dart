import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../core/errors/exceptions.dart';
import '../core/utils/path_validator.dart';
import '../models/archive_node.dart';

/// Reads ZIP / TAR archives into an [ArchiveNode] tree.
class ArchiveService {
  ArchiveService._();
  static final ArchiveService instance = ArchiveService._();

  Future<ArchiveNode> readTree(String archivePath) async {
    final safe = PathValidator.validateOrThrow(archivePath);
    final file = File(safe);
    if (!await file.exists()) throw const FileNotFoundFailure();
    try {
      final ext = p.extension(safe).toLowerCase();
      final bytes = await file.readAsBytes();
      Archive archive;
      if (ext == '.zip') {
        archive = ZipDecoder().decodeBytes(bytes);
      } else if (ext == '.tar') {
        archive = TarDecoder().decodeBytes(bytes);
      } else if (ext == '.gz' || ext == '.tgz') {
        final decompressed = GZipDecoder().decodeBytes(bytes);
        archive = TarDecoder().decodeBytes(decompressed);
      } else {
        archive = ZipDecoder().decodeBytes(bytes);
      }
      return _buildTree(archive, p.basename(safe));
    } catch (e) {
      if (e is FileClawException) rethrow;
      throw const CorruptArchiveFailure();
    }
  }

  ArchiveNode _buildTree(Archive archive, String rootName) {
    final root = ArchiveNode(name: rootName, isDirectory: true);
    final dirIndex = <String, ArchiveNode>{'': root};

    for (final entry in archive) {
      final pathInArchive = entry.name.replaceAll('\\', '/');
      final segments = pathInArchive.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty) continue;

      // ensure intermediate directories exist
      var parent = root;
      var accum = '';
      for (var i = 0; i < segments.length - 1; i++) {
        accum = accum.isEmpty ? segments[i] : '$accum/${segments[i]}';
        var dir = dirIndex[accum];
        if (dir == null) {
          dir = ArchiveNode(
            name: segments[i],
            isDirectory: true,
            pathInArchive: accum,
            parentPath: i == 0 ? null : segments.sublist(0, i).join('/'),
          );
          dirIndex[accum] = dir;
          parent.children.add(dir);
        }
        parent = dir;
      }

      final isDir = entry.isFile == false;
      final fullPath = segments.join('/');
      if (isDir) {
        if (!dirIndex.containsKey(fullPath)) {
          final node = ArchiveNode(
            name: segments.last,
            isDirectory: true,
            pathInArchive: fullPath,
          );
          dirIndex[fullPath] = node;
          parent.children.add(node);
        }
      } else {
        parent.children.add(ArchiveNode(
          name: segments.last,
          isDirectory: false,
          pathInArchive: fullPath,
          size: entry.size,
          modifiedDate: entry.lastModDateTime,
        ));
      }
    }
    _sort(root);
    return root;
  }

  void _sort(ArchiveNode node) {
    node.children.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    for (final c in node.children) {
      if (c.isDirectory) _sort(c);
    }
  }

  /// Reads a single entry's content as bytes from the archive.
  Future<List<int>?> extractEntry(String archivePath, String entryPath) async {
    final safe = PathValidator.validateOrThrow(archivePath);
    final file = File(safe);
    if (!await file.exists()) throw const FileNotFoundFailure();
    try {
      final ext = p.extension(safe).toLowerCase();
      final bytes = await file.readAsBytes();
      Archive archive;
      if (ext == '.zip') {
        archive = ZipDecoder().decodeBytes(bytes);
      } else if (ext == '.tar') {
        archive = TarDecoder().decodeBytes(bytes);
      } else if (ext == '.gz' || ext == '.tgz') {
        final decompressed = GZipDecoder().decodeBytes(bytes);
        archive = TarDecoder().decodeBytes(decompressed);
      } else {
        archive = ZipDecoder().decodeBytes(bytes);
      }
      for (final entry in archive) {
        final name = entry.name.replaceAll('\\', '/');
        if (name == entryPath && entry.isFile) {
          return entry.content as List<int>;
        }
      }
      return null;
    } catch (e) {
      throw const CorruptArchiveFailure();
    }
  }

  /// Counts files and total uncompressed size for the archive header.
  ({int fileCount, int totalSize}) summarise(ArchiveNode root) {
    int files = 0;
    int total = 0;
    void visit(ArchiveNode n) {
      for (final c in n.children) {
        if (c.isDirectory) {
          visit(c);
        } else {
          files++;
          total += c.size ?? 0;
        }
      }
    }
    visit(root);
    return (fileCount: files, totalSize: total);
  }
}
