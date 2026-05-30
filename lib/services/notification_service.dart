import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// Wrapper around flutter_local_notifications for Files Claw status messages.
///
/// We post:
///   - Transient notifications when a file opens/saves (if user enabled).
///   - A persistent notification while a floating session is active.
class AppNotificationService {
  AppNotificationService._();
  static final AppNotificationService instance = AppNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Logger _log = Logger();
  bool _initialised = false;

  static const String _channelTransient = 'files_claw_status';

  Future<void> init() async {
    if (_initialised) return;
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _plugin.initialize(initSettings);

      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await android?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelTransient,
            'Status',
            description: 'File open and save notifications',
            importance: Importance.low,
          ),
        );
      }
      _initialised = true;
    } catch (e, st) {
      _log.w('Notification init failed', error: e, stackTrace: st);
    }
  }

  Future<void> notifyTransient(String title, String body) async {
    if (!_initialised) await init();
    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 & 0x7fffffff,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelTransient,
            'Status',
            channelDescription: 'File open and save notifications',
            importance: Importance.low,
            priority: Priority.low,
            color: null,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    } catch (e) {
      _log.w('notifyTransient failed: $e');
    }
  }

  Future<void> showFileOpenNotification(String fileName) async {
    if (!_initialised) await init();
    try {
      await _plugin.show(
        fileName.hashCode,
        'Files Claw — $fileName',
        'Tap to open the file',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelTransient,
            'Status',
            channelDescription: 'File open and save notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    } catch (e) {
      _log.w('showFileOpenNotification failed: $e');
    }
  }

  Future<void> showFileSaveNotification(String fileName) async {
    if (!_initialised) await init();
    try {
      await _plugin.show(
        fileName.hashCode.abs() + 1,
        'Files Claw — $fileName',
        'File saved successfully',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelTransient,
            'Status',
            channelDescription: 'File open and save notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    } catch (e) {
      _log.w('showFileSaveNotification failed: $e');
    }
  }
}
