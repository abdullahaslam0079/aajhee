import 'package:dio/dio.dart';
import 'package:aajhee/src/config/app_config.dart';
import 'package:aajhee/src/features/notifications/data/models/app_notification.dart';
import 'package:aajhee/src/utils/utils.dart';

class NotificationPushPreferences {
  const NotificationPushPreferences({
    required this.pushEnabled,
    required this.marketingPushEnabled,
  });

  final bool pushEnabled;
  final bool marketingPushEnabled;
}

class NotificationService {
  NotificationService();
  static final NotificationService instance = NotificationService();

  Dio get _dio => AppConfig.dio;

  FutureEither<NotificationPage> fetchNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    return runTask(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/notifications',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      return NotificationPage.fromJson(response.data ?? const {});
    }, requiresNetwork: true);
  }

  FutureEither<int> fetchUnreadCount() async {
    return runTask(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/notifications/unread-count',
      );
      return parseApiInt(response.data?['unread_count']);
    }, requiresNetwork: true);
  }

  FutureEither<AppNotification> markRead(int notificationId) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/notifications/$notificationId/read',
      );
      return AppNotification.fromJson(response.data ?? const {});
    }, requiresNetwork: true);
  }

  FutureEither<void> markAllRead() async {
    return runTask(() async {
      await _dio.post<Map<String, dynamic>>('/api/notifications/read-all');
    }, requiresNetwork: true);
  }

  FutureEither<void> registerDevice({
    required String token,
    required String platform,
    String? apnsToken,
  }) async {
    return runTask(() async {
      final data = <String, dynamic>{
        'token': token,
        'platform': platform,
      };
      final apns = apnsToken?.trim();
      if (apns != null && apns.isNotEmpty) {
        data['apns_token'] = apns;
      }
      await _dio.post<Map<String, dynamic>>(
        '/api/devices',
        data: data,
      );
    }, requiresNetwork: true);
  }

  FutureEither<void> unregisterDevice(String token) async {
    return runTask(() async {
      await _dio.delete<Map<String, dynamic>>(
        '/api/devices/$token',
      );
    }, requiresNetwork: true);
  }

  FutureEither<NotificationPushPreferences>
      fetchNotificationPreferences() async {
    return runTask(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/user/preferences',
      );
      final data = response.data ?? const <String, dynamic>{};
      return NotificationPushPreferences(
        pushEnabled: data['notifications_enabled'] as bool? ?? true,
        marketingPushEnabled:
            data['marketing_notifications_enabled'] as bool? ?? true,
      );
    }, requiresNetwork: true);
  }

  FutureEither<bool> setPushEnabled(bool enabled) async {
    return runTask(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/user/preferences',
        data: {'notifications_enabled': enabled},
      );
      return response.data?['notifications_enabled'] as bool? ?? enabled;
    }, requiresNetwork: true);
  }

  FutureEither<bool> setMarketingPushEnabled(bool enabled) async {
    return runTask(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/user/preferences',
        data: {'marketing_notifications_enabled': enabled},
      );
      return response.data?['marketing_notifications_enabled'] as bool? ??
          enabled;
    }, requiresNetwork: true);
  }

  FutureEither<String> fetchThemePreference() async {
    return runTask(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/user/preferences',
      );
      return response.data?['theme_preference'] as String? ?? 'system';
    }, requiresNetwork: true);
  }

  FutureEither<String> setThemePreference(String preference) async {
    return runTask(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/api/user/preferences',
        data: {'theme_preference': preference},
      );
      return response.data?['theme_preference'] as String? ?? preference;
    }, requiresNetwork: true);
  }
}
