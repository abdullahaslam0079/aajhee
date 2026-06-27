import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../utils/utils.dart';
import 'secure_storage_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const accessTokenKey = 'auth_access_token';
  static const userKey = 'auth_user';

  String? _cachedAccessToken;

  Dio get _dio => AppConfig.dio;

  final StreamController<Map<String, dynamic>?> _authStateController =
      StreamController<Map<String, dynamic>?>.broadcast();

  Stream<Map<String, dynamic>?> get authStateChanges =>
      _authStateController.stream;

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>('/api/auth/token', data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      await _persistSession(data, email: email);
      final sessionUser = await _readStoredUser();
      _authStateController.add(sessionUser);
      return data;
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>('/api/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      await _persistSession(data, email: email, name: name);
      final sessionUser = await _readStoredUser();
      _authStateController.add(sessionUser);
      return data;
    }, requiresNetwork: true);
  }

  FutureEither<void> forgotPassword({required String email}) async {
    return runTask(() async {
      await _dio.post<Map<String, dynamic>>('/auth/forgot-password', data: {'email': email});
    }, requiresNetwork: true);
  }

  FutureEither<void> logout() async {
    return runTask(() async {
      await _clearSession();
      _authStateController.add(null);
    });
  }

  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    return runTask(() async {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      return _readStoredUser();
    });
  }

  /// Returns the JWT access token, preferring the in-memory cache from login.
  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null && _cachedAccessToken!.isNotEmpty) {
      return _cachedAccessToken;
    }

    final tokenResult =
        await SecureStorageService.instance.read(accessTokenKey);
    final token = tokenResult.fold((_) => null, (value) => value);
    if (token == null || token.isEmpty) {
      return null;
    }

    _cachedAccessToken = _normalizeToken(token);
    return _cachedAccessToken;
  }

  Future<void> restoreAccessToken() async {
    final tokenResult =
        await SecureStorageService.instance.read(accessTokenKey);
    tokenResult.fold(
      (_) => _cachedAccessToken = null,
      (value) {
        _cachedAccessToken =
            value != null && value.isNotEmpty ? _normalizeToken(value) : null;
      },
    );
  }

  String _normalizeToken(String token) {
    final trimmed = token.trim();
    if (trimmed.toLowerCase().startsWith('bearer ')) {
      return trimmed.substring(7).trim();
    }
    return trimmed;
  }

  Future<void> _persistSession(
    Map<String, dynamic> data, {
    String? email,
    String? name,
  }) async {
    final token = data['access'] ?? data['access_token'] ?? data['token'];
    if (token != null) {
      final normalizedToken = _normalizeToken(token.toString());
      _cachedAccessToken = normalizedToken;

      final writeResult = await SecureStorageService.instance.write(
        accessTokenKey,
        normalizedToken,
      );
      writeResult.fold(
        (failure) => AppLogger.error(
          'Failed to persist auth token to secure storage',
          failure,
        ),
        (_) {},
      );
    }

    final rawUser = data['user'];
    final user = rawUser is Map<String, dynamic> ? rawUser : data;
    final sessionUser = <String, dynamic>{
      if (user['id'] != null) 'id': user['id'].toString(),
      if (user['email'] != null) 'email': user['email'],
      if (user['name'] != null) 'name': user['name'],
      if (user['photoUrl'] != null) 'photoUrl': user['photoUrl'],
      if (email != null && user['email'] == null) 'email': email,
      if (name != null && user['name'] == null) 'name': name,
    };

    if (sessionUser.isNotEmpty) {
      await SecureStorageService.instance.write(
        userKey,
        jsonEncode(sessionUser),
      );
    }
  }

  Future<Map<String, dynamic>?> _readStoredUser() async {
    final userResult = await SecureStorageService.instance.read(userKey);
    final userJson = userResult.fold((_) => null, (value) => value);
    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  Future<void> _clearSession() async {
    _cachedAccessToken = null;
    await SecureStorageService.instance.delete(accessTokenKey);
    await SecureStorageService.instance.delete(userKey);
  }

  void dispose() {
    _authStateController.close();
  }
}
