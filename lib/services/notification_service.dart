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
  static const String _channelOngoing = 'files_claw_ongoing';

  Future<void> init() async {
    if (_initialised) return;
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          // If user taps the ongoing notification, we just want to bring the app
          // to foreground. Navigation is handled natively by reopening the activity.
        },
      );

      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        await android?.requestNotificationsPermission();

        await android?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelTransient,
            'Status',
            description: 'File open and save notifications',
            importance: Importance.high,
          ),
        );

        await android?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelOngoing,
            'Active File',
            description: 'Silent ongoing notification for the currently open file',
            importance: Importance.low,
            playSound: false,
            enableVibration: false,
          ),
        );
      }
      _initialised = true;
    } catch (e, st) {
      _log.w('Notification init failed', error: e, stackTrace: st);
    }
  }

  Future<void> showFileOngoingNotification(String fileName) async {
    if (!_initialised) await init();
    try {
      await _plugin.show(
        fileName.hashCode.abs() + 2, // Ensure uniqueness
        'Currently Viewing',
        fileName,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelOngoing,
            'Active File',
            channelDescription: 'Silent ongoing notification for the currently open file',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            playSound: false,
            enableVibration: false,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: fileName,
      );
    } catch (e) {
      _log.w('showFileOngoingNotification failed: $e');
    }
  }

  Future<void> cancelFileOngoingNotification(String fileName) async {
    if (!_initialised) return;
    try {
      await _plugin.cancel(fileName.hashCode.abs() + 2);
    } catch (e) {
      _log.w('cancelFileOngoingNotification failed: $e');
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
        fileName.hashCode.abs(),
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
