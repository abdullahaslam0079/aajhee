import 'package:goluto/src/features/auth/data/models/user_model.dart';
import 'package:goluto/src/features/auth/domain/entities/auth_session.dart';
import 'package:goluto/src/features/auth/domain/entities/user.dart';
import 'package:goluto/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:goluto/src/features/settings/domain/entities/saved_address.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService.instance;

  @override
  Stream<AppUser?> get onAuthStateChanged {
    return _authService.authStateChanges.map((userData) {
      if (userData == null) return null;
      return UserModel.fromJson(userData).toEntity();
    });
  }

  @override
  FutureEither<AuthSession> loginWithFirebase({
    required String idToken,
  }) async {
    final result = await _authService.loginWithFirebase(idToken: idToken);

    return result.flatMap((response) {
      if (response == null) {
        return left(const ServerFailure('Login failed: User record not found'));
      }

      return right(_parseAuthSession(response));
    });
  }

  @override
  FutureEither<AuthSession> loginWithPhone({
    required String idToken,
  }) {
    return loginWithFirebase(idToken: idToken);
  }

  AuthSession _parseAuthSession(Map<String, dynamic> response) {
    final rawUser = response['user'] ?? response;
    final user = UserModel.fromJson(
      Map<String, dynamic>.from(rawUser as Map),
    ).toEntity();

    final addresses = _parseAddresses(response['addresses']);

    return AuthSession(user: user, addresses: addresses);
  }

  List<SavedAddress> _parseAddresses(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(SavedAddress.fromJson)
        .toList();
  }

  @override
  FutureEither<void> logout() {
    return _authService.logout();
  }

  @override
  FutureEither<AppUser?> checkAuthState() async {
    final result = await _authService.getCurrentUser();

    return result.map((userData) {
      if (userData == null) return null;

      return UserModel.fromJson(userData).toEntity();
    });
  }
}
