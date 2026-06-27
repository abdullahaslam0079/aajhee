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
  FutureEither<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final result = await _authService.login(email: email, password: password);

    return result.flatMap((response) {
      if (response == null) {
        return left(const ServerFailure('Login failed: User record not found'));
      }

      return right(_parseAuthSession(response, email: email));
    });
  }

  @override
  FutureEither<String> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  }) {
    return _authService.signUp(
      name: name,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
    );
  }

  AuthSession _parseAuthSession(
    Map<String, dynamic> response, {
    String? email,
    String? name,
  }) {
    final rawUser = response['user'] ?? response;
    final user = UserModel.fromJson({
      ...Map<String, dynamic>.from(rawUser as Map),
      if (rawUser['email'] == null && email != null) 'email': email,
      if (rawUser['name'] == null && name != null) 'name': name,
    }).toEntity();

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
  FutureEither<void> forgotPassword({required String email}) {
    return _authService.forgotPassword(email: email);
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
