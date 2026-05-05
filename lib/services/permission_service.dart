import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Centralised wrapper around runtime permission requests.
///
/// All Files Claw permissions are best-effort — if the user denies them,
/// we degrade gracefully (e.g., show a rationale) rather than crashing.
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  Future<bool> ensureNotifications() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final res = await Permission.notification.request();
    return res.isGranted;
  }

  Future<bool> ensureStorage() async {
    if (!Platform.isAndroid) return true;
    // On Android 13+ READ_EXTERNAL_STORAGE is replaced by media perms.
    // The SAF-based file_picker doesn't strictly need storage perms,
    // but legacy paths (Download/) sometimes do.
    final status = await Permission.storage.status;
    if (status.isGranted || status.isLimited) return true;
    final res = await Permission.storage.request();
    return res.isGranted || res.isLimited;
  }

  Future<bool> requestManageExternalStorage() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.manageExternalStorage.status;
    if (status.isGranted) return true;
    final res = await Permission.manageExternalStorage.request();
    return res.isGranted;
  }

  Future<PermissionStatus> notificationStatus() async {
    if (!Platform.isAndroid) return PermissionStatus.granted;
    return Permission.notification.status;
  }

  Future<PermissionStatus> storageStatus() async {
    if (!Platform.isAndroid) return PermissionStatus.granted;
    return Permission.storage.status;
  }
}
