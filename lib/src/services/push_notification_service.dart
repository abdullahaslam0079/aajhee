import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:aajhee/src/features/notifications/data/push_notification_payload.dart';
import 'package:aajhee/src/features/notifications/data/services/notification_service.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:aajhee/src/routing/global_navigator.dart';
import 'package:aajhee/src/services/auth_service.dart';
import 'package:aajhee/src/services/secure_storage_service.dart';
import 'package:aajhee/src/utils/logger.dart';
import 'package:go_router/go_router.dart';

/// Must remain a top-level function for the background isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Placeholder Firebase config may fail; ignore in background isolate.
  }

  // Notification+data messages are displayed by the OS when backgrounded.
  // Data-only messages need a local notification here.
  if (message.notification != null) return;

  final title = message.data['title']?.toString();
  final body = message.data['body']?.toString();
  if (title == null && body == null) return;

  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  await plugin.initialize(
    const InitializationSettings(android: androidInit, iOS: iosInit),
  );

  final androidPlugin = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      PushNotificationService.androidChannelId,
      PushNotificationService.androidChannelName,
      description: 'Orders and account updates',
      importance: Importance.high,
    ),
  );

  await plugin.show(
    message.hashCode,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        PushNotificationService.androidChannelId,
        PushNotificationService.androidChannelName,
        channelDescription: 'Orders and account updates',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: encodeLocalNotificationPayload(
      Map<String, dynamic>.from(message.data),
    ),
  );
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const _tokenStorageKey = 'fcm_device_token';
  static const androidChannelId = 'aajhee_default';
  static const androidChannelName = 'Aajhee';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _nativeLogChannel = MethodChannel('aajhee/push_debug');
  static const _tokenDebugFileName = 'fcm_token.txt';

  bool _initialized = false;
  bool _firebaseReady = false;
  bool _backgroundHandlerRegistered = false;

  /// Called when a push is opened (tap) or cold-started from a notification.
  void Function(Map<String, dynamic> data)? onNotificationOpened;

  /// Called when a push arrives while the app is in the foreground.
  void Function(Map<String, dynamic> data)? onForegroundMessage;

  /// Register before [runApp]. Safe to call multiple times.
  void registerBackgroundHandler() {
    if (_backgroundHandlerRegistered) return;
    _backgroundHandlerRegistered = true;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Mirror push diagnostics to iOS NSLog (debug builds only).
  Future<void> _deviceLog(String message) async {
    if (!kDebugMode) return;
    debugPrint(message);
    if (!Platform.isIOS) return;
    try {
      await _nativeLogChannel.invokeMethod<void>('log', message);
    } catch (_) {
      // Channel may not be ready yet; debugPrint above still applies.
    }
  }

  Future<void> _writeDebugTokenFile(
    String token, {
    String fileName = _tokenDebugFileName,
  }) async {
    if (!kDebugMode) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      await File('${dir.path}/$fileName').writeAsString(token);
    } catch (_) {}
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Hook session wipe so expiry/logout always clears FCM (avoids import cycle
    // if AuthService imported this service directly).
    AuthService.instance.onBeforeClearSession = clearOnSessionEnd;

    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
      registerBackgroundHandler();
      await _deviceLog('[Aajhee] Firebase initialized');
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Firebase not configured; push notifications disabled until '
        'google-services.json / GoogleService-Info.plist are added. $error',
      );
      AppLogger.error('Firebase init failed', [error, stackTrace]);
      await _deviceLog('[Aajhee] Firebase init failed: $error');
      return;
    }

    await _initLocalNotifications();

    final messaging = FirebaseMessaging.instance;
    // Avoid iOS double banners: OS presentation alert off; local plugin shows.
    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _handleOpenedMessage(initial);
    }

    messaging.onTokenRefresh.listen((token) {
      unawaited(_onTokenRefresh(token));
    });
  }

  Future<void> _onTokenRefresh(String token) async {
    String? apnsToken;
    if (Platform.isIOS && _firebaseReady) {
      try {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      } catch (_) {}
    }
    await _persistAndRegisterToken(token, apnsToken: apnsToken);
  }

  Future<bool> syncForAuthenticatedUser() async {
    if (!_firebaseReady) return false;

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
        await _deviceLog(
          '[Aajhee] Push permission not granted: ${settings.authorizationStatus}',
        );
        return false;
      }

      // Android 13+: runtime POST_NOTIFICATIONS is required for trays/banners.
      if (Platform.isAndroid) {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidPlugin?.requestNotificationsPermission();
        await _deviceLog('[Aajhee] Android notification permission: $granted');
        if (granted == false) {
          AppLogger.info('Android notification permission denied.');
          return false;
        }
      }

      String? apnsToken;
      if (Platform.isIOS) {
        // APNs requires paid Apple Developer + Push capability.
        // Without it, getToken() throws — skip FCM registration cleanly.
        for (var i = 0; i < 15; i++) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken != null && apnsToken.isNotEmpty) break;
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
        await _deviceLog(
          '[Aajhee] APNs token ready: ${apnsToken != null && apnsToken.isNotEmpty}',
        );
        if (apnsToken == null || apnsToken.isEmpty) {
          AppLogger.warning(
            'APNs token unavailable; skipping iOS FCM registration. '
            'In-app inbox still works. Enable Push Notifications with a '
            'paid Apple Developer account for OS banners.',
          );
          await _deviceLog(
            '[Aajhee] Skipping FCM on iOS (no APNs). Inbox notifications still work.',
          );
          return false;
        }
        await _writeDebugTokenFile(apnsToken, fileName: 'apns_token.txt');
      }

      final token = await messaging.getToken();
      if (token == null || token.isEmpty) {
        AppLogger.warning('FCM token unavailable.');
        await _deviceLog('[Aajhee] FCM token unavailable');
        return false;
      }

      await _writeDebugTokenFile(token);
      await _deviceLog('[Aajhee] FCM token acquired (${token.length} chars)');
      if (kDebugMode) {
        await _deviceLog('[Aajhee] FCM token: $token');
      }
      return _persistAndRegisterToken(token, apnsToken: apnsToken);
    } catch (error, stackTrace) {
      AppLogger.warning('Push sync skipped: $error');
      AppLogger.error('Push sync failed', [error, stackTrace]);
      await _deviceLog('[Aajhee] Push sync skipped: $error');
      return false;
    }
  }

  /// Best-effort backend unregister + always invalidate local FCM token.
  ///
  /// Safe to call when the JWT may already be expired (session expiry).
  Future<void> clearOnSessionEnd() async {
    final tokenResult =
        await SecureStorageService.instance.read(_tokenStorageKey);
    final token = tokenResult.fold((_) => null, (value) => value);
    if (token != null && token.isNotEmpty) {
      try {
        await NotificationService.instance.unregisterDevice(token);
      } catch (_) {}
    }

    await SecureStorageService.instance.delete(_tokenStorageKey);

    if (_firebaseReady) {
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}
    }
  }

  Future<void> unregisterCurrentDevice() async {
    final tokenResult =
        await SecureStorageService.instance.read(_tokenStorageKey);
    final token = tokenResult.fold((_) => null, (value) => value);
    if (token == null || token.isEmpty) {
      // Still invalidate FCM so the OS token cannot receive stale pushes.
      if (_firebaseReady) {
        try {
          await FirebaseMessaging.instance.deleteToken();
        } catch (_) {}
      }
      return;
    }

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
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final data = decodeLocalNotificationPayload(response.payload);
        unawaited(_markInboxReadFromPushData(data));
        onNotificationOpened?.call(data);
        _navigateFromPushData(data);
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        androidChannelId,
        androidChannelName,
        description: 'Orders and account updates',
        importance: Importance.high,
      ),
    );

    // Cold-start from a local notification tap (foreground-shown pushes).
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final data =
          decodeLocalNotificationPayload(launchDetails!.notificationResponse?.payload);
      if (data.isNotEmpty) {
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          unawaited(_markInboxReadFromPushData(data));
          onNotificationOpened?.call(data);
          _navigateFromPushData(data);
        });
      }
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final data = Map<String, dynamic>.from(message.data);
    onForegroundMessage?.call(data);

    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannelId,
          androidChannelName,
          channelDescription: 'Orders and account updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: encodeLocalNotificationPayload(data),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    unawaited(_markInboxReadFromPushData(data));
    onNotificationOpened?.call(data);
    _navigateFromPushData(data);
  }

  Future<void> _markInboxReadFromPushData(Map<String, dynamic> data) async {
    final raw = data[PushDataKeys.notificationId];
    final id = int.tryParse(raw?.toString() ?? '');
    if (id == null) return;
    try {
      await NotificationService.instance.markRead(id);
    } catch (_) {}
  }

  void _navigateFromPushData(Map<String, dynamic> data) {
    final context = rootContext;
    if (context == null) {
      // Router may not be ready yet (cold start); retry shortly.
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (rootContext != null) _navigateFromPushData(data);
      });
      return;
    }

    final orderPublicId = orderPublicIdFromPushData(data);
    if (orderPublicId != null) {
      context.push(AppRoutes.orderDetail(orderPublicId));
      return;
    }

    final productRoute = productRouteFromPushData(data);
    if (productRoute != null) {
      context.push(productRoute);
      return;
    }

    context.push(AppRoutes.notifications);
  }

  Future<bool> _persistAndRegisterToken(
    String token, {
    String? apnsToken,
  }) async {
    await SecureStorageService.instance.write(_tokenStorageKey, token);
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    final result = await NotificationService.instance.registerDevice(
      token: token,
      platform: platform,
      apnsToken: apnsToken,
    );
    return result.fold(
      (failure) {
        AppLogger.warning(
          'Failed to register device token: ${failure.message}',
        );
        unawaited(
          _deviceLog('[Aajhee] Device register failed: ${failure.message}'),
        );
        return false;
      },
      (_) {
        AppLogger.info('Device token registered for push.');
        unawaited(_deviceLog('[Aajhee] Device token registered for push'));
        return true;
      },
    );
  }
}
