import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';

/// Resolves and lazily creates the directories Files Claw uses for JSON
/// persistence. All paths live under the app's private documents folder
/// (i.e., /Android/data/<pkg>/files/), keeping data out of public storage.
class StoragePaths {
  StoragePaths._();
  static StoragePaths? _instance;
  static StoragePaths get instance => _instance ??= StoragePaths._();

  Directory? _root;

  Future<Directory> _ensureRoot() async {
    if (_root != null) return _root!;
    final docs = await getApplicationDocumentsDirectory();
    _root = docs;
    return docs;
  }

  Future<Directory> configDir() async {
    final root = await _ensureRoot();
    final dir = Directory(p.join(root.path, AppConstants.configDir));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> historyDir() async {
    final root = await _ensureRoot();
    final dir = Directory(p.join(root.path, AppConstants.historyDir));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> editorCacheDir() async {
    final root = await _ensureRoot();
    final dir = Directory(p.join(root.path, AppConstants.editorCacheDir));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> configFile() async {
    final dir = await configDir();
    return File(p.join(dir.path, AppConstants.configFileName));
  }

  Future<File> historyFile() async {
    final dir = await historyDir();
    return File(p.join(dir.path, AppConstants.historyFileName));
  }

  Future<File> floatingSessionFile() async {
    final dir = await configDir();
    return File(p.join(dir.path, AppConstants.floatingSessionFileName));
  }

  Future<File> editorCacheFile(String fileId) async {
    final dir = await editorCacheDir();
    final safeId = fileId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return File(p.join(dir.path, '$safeId.json'));
  }
}
