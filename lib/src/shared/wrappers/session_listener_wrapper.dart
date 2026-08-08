import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto/src/features/notifications/presentation/providers/notifications_provider.dart';
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
        final isExplicitLogout = AuthService.instance.consumeExplicitLogout();
        _redirectToLogin(showExpiredMessage: !isExplicitLogout);
      }
    });

    return child;
  }

  void _redirectToLogin({required bool showExpiredMessage}) {
    final context = rootContext;
    if (context == null) return;

    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
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
