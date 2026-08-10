import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto/src/features/availedOffers/presentation/providers/availed_offers_provider.dart';
import 'package:goluto/src/features/offers/presentation/providers/top_picks_provider.dart';
import 'package:goluto/src/features/offers/presentation/providers/all_offers_provider.dart';
import 'package:goluto/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:goluto/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:goluto/src/features/location/presentation/providers/location_provider.dart';
import 'package:goluto/src/features/notifications/presentation/providers/notification_preferences_provider.dart';
import 'package:goluto/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:goluto/src/features/searchOffers/presentation/providers/search_offers_provider.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/features/settings/presentation/providers/theme_preferences_provider.dart';
import 'package:goluto/src/features/settings/presentation/providers/user_profile_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class SessionListenerWrapper extends ConsumerWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  static const _publicRoutes = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.forgotPassword,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next.status != SessionStatus.unknown) {
        FlutterNativeSplash.remove();
      }

      if (next.status == SessionStatus.authenticated &&
          prev?.status != SessionStatus.authenticated) {
        PushNotificationService.instance.syncForAuthenticatedUser();
        PushNotificationService.instance.onForegroundMessage = () {
          ref.read(notificationsProvider.notifier).refreshUnreadCount();
        };
        PushNotificationService.instance.onNotificationOpened = (_) {
          ref.read(notificationsProvider.notifier).refreshUnreadCount();
        };
      }

      final becameUnauthenticated =
          next.status == SessionStatus.unauthenticated &&
          prev?.status == SessionStatus.authenticated;

      if (becameUnauthenticated) {
        PushNotificationService.instance.onForegroundMessage = null;
        PushNotificationService.instance.onNotificationOpened = null;
        _invalidateUserCaches(ref);
        final isExplicitLogout = AuthService.instance.consumeExplicitLogout();
        _redirectToLogin(showExpiredMessage: !isExplicitLogout);
      }
    });

    return child;
  }

  void _invalidateUserCaches(WidgetRef ref) {
    ref.invalidate(savedAddressesProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(favoriteStoresProvider);
    ref.invalidate(homeFeedProvider);
    ref.invalidate(topPicksFeedProvider);
    ref.invalidate(allOffersFeedProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(notificationPreferencesProvider);
    ref.invalidate(themePreferencesProvider);
    ref.invalidate(searchOffersProvider);
    ref.invalidate(availedOffersProvider);
    ref.invalidate(locationProvider);
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
