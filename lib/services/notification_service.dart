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
  static const String _channelPersistent = 'files_claw_floating';
  static const int _persistentId = 9001;

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
        await android?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelPersistent,
            'Floating Window',
            description: 'Persistent notification while a file is open',
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

  Future<void> showFloating(String fileName) async {
    if (!_initialised) await init();
    try {
      await _plugin.show(
        _persistentId,
        'Files Claw — $fileName',
        'Tap to open the floating preview.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelPersistent,
            'Floating Window',
            channelDescription: 'Persistent notification for floating preview',
            ongoing: true,
            autoCancel: false,
            importance: Importance.low,
            priority: Priority.low,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    } catch (e) {
      _log.w('showFloating failed: $e');
    }
  }

  Future<void> dismissFloating() async {
    if (!_initialised) await init();
    try {
      await _plugin.cancel(_persistentId);
    } catch (_) {}
  }
}
