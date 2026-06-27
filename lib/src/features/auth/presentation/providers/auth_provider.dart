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

  void login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    state = true;

    final result = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);

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

        if (!context.mounted) return;

        navigateAfterAuthentication(
          context,
          hasSavedAddress: session.hasSavedAddress,
        );
      },
    );
  }

  void signUp({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    state = true;

    final result = await ref.read(authRepositoryProvider).signUp(
          name: name,
          email: email,
          password: password,
          passwordConfirm: passwordConfirm,
        );

    state = false;
    result.fold(
      (failure) =>
          showToast(context, message: failure.message, status: 'error'),
      (message) {
        showToast(context, message: message, status: 'success');
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
    );
  }

  void forgotPassword({
    required BuildContext context,
    required String email,
  }) async {
    state = true;

    final result =
        await ref.read(authRepositoryProvider).forgotPassword(email: email);

    state = false;
    result.fold(
      (failure) =>
          showToast(context, message: failure.message, status: 'error'),
      (success) {
        showToast(
          context,
          message: 'Password reset link sent successfully',
          status: 'success',
        );
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
    );
  }
}
