import 'package:goluto/src/features/auth/domain/entities/auth_session.dart';
import 'package:goluto/src/features/auth/domain/entities/user.dart';
import 'package:goluto/src/utils/utils.dart';

abstract class AuthRepository {
  /// Stream of auth state changes. Emits AppUser when authenticated, null when not.
  Stream<AppUser?> get onAuthStateChanged;

  /// Sign in / sign up with a Firebase Phone Auth ID token.
  FutureEither<AuthSession> loginWithPhone({
    required String idToken,
  });

  /// Sign out the current user
  FutureEither<void> logout();

  /// Check if the user is currently authenticated natively
  FutureEither<AppUser?> checkAuthState();
}
