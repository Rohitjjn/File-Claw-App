import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/notification_service.dart';

/// Wraps [AppNotificationService] for use via Riverpod.
final notificationServiceProvider = Provider<AppNotificationService>((ref) {
  return AppNotificationService.instance;
});
