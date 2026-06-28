import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto/src/routing/app_routes.dart';
import 'package:goluto/src/routing/global_navigator.dart';
import 'package:goluto/src/services/auth_service.dart';
import 'package:goluto/src/shared/helpers/show_toast.dart';

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

      final becameUnauthenticated =
          next.status == SessionStatus.unauthenticated &&
          prev?.status == SessionStatus.authenticated;

      if (becameUnauthenticated) {
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
