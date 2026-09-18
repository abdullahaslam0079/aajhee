import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:aajhee/src/features/notifications/data/services/notification_service.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:aajhee/src/routing/global_navigator.dart';
import 'package:aajhee/src/services/secure_storage_service.dart';
import 'package:aajhee/src/utils/logger.dart';
import 'package:go_router/go_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Placeholder Firebase config may fail; ignore in background isolate.
  }
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const _tokenStorageKey = 'fcm_device_token';
  static const _androidChannelId = 'aajhee_default';
  static const _androidChannelName = 'Aajhee';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _firebaseReady = false;
  void Function(Map<String, dynamic> data)? onNotificationOpened;
  void Function()? onForegroundMessage;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      debugPrint('[Aajhee] Firebase initialized');
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Firebase not configured; push notifications disabled until '
        'google-services.json / GoogleService-Info.plist are added. $error',
      );
      AppLogger.error('Firebase init failed', [error, stackTrace]);
      debugPrint('[Aajhee] Firebase init failed: $error');
      return;
    }

    await _initLocalNotifications();

    final messaging = FirebaseMessaging.instance;
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _handleOpenedMessage(initial);
    }

    messaging.onTokenRefresh.listen((token) {
      unawaited(_persistAndRegisterToken(token));
    });
  }

  Future<void> syncForAuthenticatedUser() async {
    if (!_firebaseReady) return;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!authorized) {
        AppLogger.info('Push permission not granted.');
        debugPrint(
          '[Aajhee] Push permission not granted: ${settings.authorizationStatus}',
        );
        return;
      }

      if (Platform.isIOS) {
        // APNs requires paid Apple Developer + Push capability.
        // Without it, getToken() throws — skip FCM registration cleanly.
        String? apns;
        for (var i = 0; i < 10; i++) {
          apns = await messaging.getAPNSToken();
          if (apns != null && apns.isNotEmpty) break;
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
        debugPrint('[Aajhee] APNs token ready: ${apns != null && apns.isNotEmpty}');
        if (apns == null || apns.isEmpty) {
          AppLogger.warning(
            'APNs token unavailable; skipping iOS FCM registration. '
            'In-app inbox still works. Enable Push Notifications with a '
            'paid Apple Developer account for OS banners.',
          );
          debugPrint(
            '[Aajhee] Skipping FCM on iOS (no APNs). Inbox notifications still work.',
          );
          return;
        }
      }

      final token = await messaging.getToken();
      if (token == null || token.isEmpty) {
        AppLogger.warning('FCM token unavailable.');
        debugPrint('[Aajhee] FCM token unavailable');
        return;
      }

      debugPrint('[Aajhee] FCM token acquired (${token.length} chars)');
      await _persistAndRegisterToken(token);
    } catch (error, stackTrace) {
      AppLogger.warning('Push sync skipped: $error');
      AppLogger.error('Push sync failed', [error, stackTrace]);
      debugPrint('[Aajhee] Push sync skipped: $error');
    }
  }

  Future<void> unregisterCurrentDevice() async {
    final tokenResult =
        await SecureStorageService.instance.read(_tokenStorageKey);
    final token = tokenResult.fold((_) => null, (value) => value);
    if (token == null || token.isEmpty) return;

    await NotificationService.instance.unregisterDevice(token);
    await SecureStorageService.instance.delete(_tokenStorageKey);

    if (_firebaseReady) {
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        // Payload is notification id only for local taps; open inbox.
        _openNotificationsScreen();
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: 'Offers and account updates',
        importance: Importance.high,
      ),
    );
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    onForegroundMessage?.call();

    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: 'Offers and account updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['notification_id']?.toString(),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    onNotificationOpened?.call(data);
    _openNotificationsScreen();
  }

  void _openNotificationsScreen() {
    final context = rootContext;
    if (context == null) return;
    context.push(AppRoutes.notifications);
  }

  Future<void> _persistAndRegisterToken(String token) async {
    await SecureStorageService.instance.write(_tokenStorageKey, token);
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    final result = await NotificationService.instance.registerDevice(
      token: token,
      platform: platform,
    );
    result.fold(
      (failure) {
        AppLogger.warning(
          'Failed to register device token: ${failure.message}',
        );
        debugPrint('[Aajhee] Device register failed: ${failure.message}');
      },
      (_) {
        AppLogger.info('Device token registered for push.');
        debugPrint('[Aajhee] Device token registered for push');
      },
    );
  }
}
