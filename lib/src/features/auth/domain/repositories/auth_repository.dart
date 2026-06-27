import 'package:goluto/src/features/auth/domain/entities/auth_session.dart';
import 'package:goluto/src/features/auth/domain/entities/user.dart';
import 'package:goluto/src/utils/utils.dart';

abstract class AuthRepository {
  /// Stream of auth state changes. Emits AppUser when authenticated, null when not.
  Stream<AppUser?> get onAuthStateChanged;

  /// Sign in with email and password
  FutureEither<AuthSession> login({
    required String email,
    required String password,
  });

  /// Sign up with email, password, and optional name
  FutureEither<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Send a password reset email
  FutureEither<void> forgotPassword({
    required String email,
  });

  /// Sign out the current user
  FutureEither<void> logout();
  
  /// Check if the user is currently authenticated natively
  FutureEither<AppUser?> checkAuthState();
}

