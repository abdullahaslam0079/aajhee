import 'dart:async';

import 'package:aajhee/src/features/auth/presentation/providers/session_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/active_orders_badge_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_realtime_provider.dart';
import 'package:aajhee/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/location/presentation/providers/location_provider.dart';
import 'package:aajhee/src/features/notifications/data/push_notification_payload.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notification_preferences_provider.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/theme_preferences_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/user_profile_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class SessionListenerWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  ConsumerState<SessionListenerWrapper> createState() =>
      _SessionListenerWrapperState();
}

class _SessionListenerWrapperState extends ConsumerState<SessionListenerWrapper>
    with WidgetsBindingObserver {
  static const _publicRoutes = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.verifyOtp,
  };

  static const _pollInterval = Duration(seconds: 30);

  Timer? _pollTimer;
  bool _pushHandlersAttached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    _detachPushHandlers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) return;
    unawaited(_refreshBackgroundState(forceInbox: false));
  }

  void _attachPushHandlers() {
    if (_pushHandlersAttached) return;
    _pushHandlersAttached = true;

    unawaited(() async {
      final ok =
          await PushNotificationService.instance.syncForAuthenticatedUser();
      if (!ok) {
        showGlobalToast(
          message:
              'Push setup incomplete. Order banners may not appear until this device is registered.',
          status: 'warning',
        );
      }
    }());
    PushNotificationService.instance.onForegroundMessage = (data) {
      unawaited(_handlePushData(data, opened: false));
    };
    PushNotificationService.instance.onNotificationOpened = (data) {
      unawaited(_handlePushData(data, opened: true));
    };
  }

  void _detachPushHandlers() {
    if (!_pushHandlersAttached) return;
    _pushHandlersAttached = false;
    PushNotificationService.instance.onForegroundMessage = null;
    PushNotificationService.instance.onNotificationOpened = null;
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      unawaited(_refreshBackgroundState(forceInbox: false));
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _handlePushData(
    Map<String, dynamic> data, {
    required bool opened,
  }) async {
    final notifications = ref.read(notificationsProvider.notifier);
    await notifications.refreshUnreadCount();

    // Refresh inbox list when it was already loaded (or user opened a push).
    final hasInbox = ref.read(notificationsProvider).notifications.isNotEmpty;
    if (opened || hasInbox) {
      await notifications.refresh();
    }

    if (isOrderRelatedPush(data)) {
      ref.read(commerceRealtimeTickProvider.notifier).bump();
      ref.invalidate(activeOrdersBadgeProvider);
    }
  }

  Future<void> _refreshBackgroundState({required bool forceInbox}) async {
    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) return;

    final notifications = ref.read(notificationsProvider.notifier);
    await notifications.refreshUnreadCount();
    ref.invalidate(activeOrdersBadgeProvider);

    if (forceInbox ||
        ref.read(notificationsProvider).notifications.isNotEmpty) {
      await notifications.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next.status != SessionStatus.unknown) {
        FlutterNativeSplash.remove();
      }

      if (next.status == SessionStatus.authenticated &&
          prev?.status != SessionStatus.authenticated) {
        _attachPushHandlers();
        _startPolling();
        unawaited(_refreshBackgroundState(forceInbox: false));
      }

      final becameUnauthenticated =
          next.status == SessionStatus.unauthenticated &&
              prev?.status == SessionStatus.authenticated;

      if (becameUnauthenticated) {
        _detachPushHandlers();
        _stopPolling();
        _invalidateUserCaches(ref);
        final isExplicitLogout = AuthService.instance.consumeExplicitLogout();
        _redirectToLogin(showExpiredMessage: !isExplicitLogout);
      }
    });

    // Attach if already authenticated on first build (e.g. restored session).
    final session = ref.watch(sessionProvider);
    if (session.status == SessionStatus.authenticated &&
        !_pushHandlersAttached) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (ref.read(sessionProvider).status != SessionStatus.authenticated) {
          return;
        }
        _attachPushHandlers();
        if (_pollTimer == null) _startPolling();
      });
    }

    return widget.child;
  }

  void _invalidateUserCaches(WidgetRef ref) {
    ref.invalidate(savedAddressesProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(favoriteStoresProvider);
    ref.invalidate(homeFeedProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(notificationPreferencesProvider);
    ref.invalidate(themePreferencesProvider);
    ref.invalidate(locationProvider);
    ref.invalidate(cartProvider);
    ref.invalidate(activeOrdersBadgeProvider);
  }

  void _redirectToLogin({required bool showExpiredMessage}) {
    final context = rootContext;
    if (context == null) return;

    final location =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    if (_publicRoutes.contains(location)) return;

    if (showExpiredMessage) {
      showGlobalToast(
        message: 'Your session has expired. Please log in again.',
        status: 'warning',
      );
    }

    context.go(AppRoutes.login);
  }
}
