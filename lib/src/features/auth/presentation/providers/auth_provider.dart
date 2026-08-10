import 'dart:async';

import 'package:goluto/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:goluto/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/features/settings/presentation/providers/user_profile_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:goluto/src/routing/app_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl();
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  bool build() => false;

  Future<void> completePhoneLogin({
    required BuildContext context,
    required String idToken,
  }) async {
    state = true;

    final result = await ref
        .read(authRepositoryProvider)
        .loginWithPhone(idToken: idToken);

    state = false;
    await result.fold(
      (failure) async {
        showToast(context, message: failure.message, status: 'error');
      },
      (session) async {
        await ref
            .read(savedAddressesProvider.notifier)
            .syncFromApi(session.addresses);
        await ref
            .read(userProfileProvider.notifier)
            .syncFromAuthUser(session.user);

        unawaited(PushNotificationService.instance.syncForAuthenticatedUser());

        if (!context.mounted) return;

        navigateAfterAuthentication(
          context,
          hasSavedAddress: session.hasSavedAddress,
        );
      },
    );
  }

  Future<void> logout({required BuildContext context}) async {
    state = true;

    await PushNotificationService.instance.unregisterCurrentDevice();

    final result = await ref.read(authRepositoryProvider).logout();

    state = false;

    if (!context.mounted) return;

    result.fold(
      (_) {},
      (_) {
        showToast(context, message: 'Logged out successfully', status: 'success');
      },
    );

    context.go(AppRoutes.login);
  }
}
