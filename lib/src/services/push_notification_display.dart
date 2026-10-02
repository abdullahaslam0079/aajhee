part of 'push_notification_service.dart';

extension PushNotificationDisplay on PushNotificationService {
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
        PushNotificationService.androidChannelId,
        PushNotificationService.androidChannelName,
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
          PushNotificationService.androidChannelId,
          PushNotificationService.androidChannelName,
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
    // Backend rejects apns_token above 128 characters. Simulator tokens
    // are often longer; omit the field so the FCM token can still register.
    var apns = apnsToken?.trim();
    if (apns != null && apns.length > 128) {
      AppLogger.warning(
        'APNs token is ${apns.length} characters (max 128). '
        'Registering the device without it.',
      );
      apns = null;
    }

    await SecureStorageService.instance.write(
      PushNotificationService._tokenStorageKey,
      token,
    );
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    final result = await NotificationService.instance.registerDevice(
      token: token,
      platform: platform,
      apnsToken: apns,
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
