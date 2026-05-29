import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../models/file_item.dart';

class LocalSearchService {
  LocalSearchService._();
  static final LocalSearchService instance = LocalSearchService._();

  static const _uuid = Uuid();

  /// Search common public directories on Android/iOS.
  Future<List<FileItem>> search(String query) async {
    if (query.isEmpty) return [];

    final results = <FileItem>[];
    final q = query.toLowerCase();

    // Determine roots to search
    List<Directory> roots = [];
    if (Platform.isAndroid) {
      roots.add(Directory('/storage/emulated/0/Download'));
      roots.add(Directory('/storage/emulated/0/Documents'));
    } else if (Platform.isIOS) {
      // Typically iOS apps can only search within their own sandbox unless using native file picker
      // We'll just search the documents dir
      // roots.add(await getApplicationDocumentsDirectory());
    }

    for (final dir in roots) {
      if (!dir.existsSync()) continue;
      try {
        await for (final entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (results.length >= 50) break; // Limit results for performance
          if (entity is File) {
            final name = p.basename(entity.path);
            if (name.toLowerCase().contains(q)) {
              try {
                final stat = await entity.stat();
                results.add(
                  FileItem.create(
                    id: _uuid.v4(),
                    name: name,
                    path: entity.path,
                    sizeInBytes: stat.size,
                    lastModified: stat.modified,
                    lastOpened: DateTime.now(),
                  ),
                );
              } catch (_) {}
            }
          }
        }
      } catch (_) {
        // ignore permission errors for specific subdirs
      }
    }
    return results;
  }
}
