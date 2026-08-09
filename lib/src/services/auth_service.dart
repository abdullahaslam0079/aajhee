import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../utils/utils.dart';
import 'cache_service.dart';
import 'secure_storage_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const accessTokenKey = 'auth_access_token';
  static const refreshTokenKey = 'auth_refresh_token';
  static const userKey = 'auth_user';

  String? _cachedAccessToken;
  var _isHandlingSessionExpiry = false;
  var _explicitLogout = false;

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

  FutureEither<String> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>('/api/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
      });
      final data = response.data as Map<String, dynamic>;
      final message = data['message'] as String?;
      return message ?? 'Account created successfully.';
    }, requiresNetwork: true);
  }

  FutureEither<void> forgotPassword({required String email}) async {
    return runTask(() async {
      await _dio.post<Map<String, dynamic>>('/auth/forgot-password', data: {'email': email});
    }, requiresNetwork: true);
  }

  /// Returns true once when logout was initiated by the user (not session expiry).
  bool consumeExplicitLogout() {
    if (!_explicitLogout) return false;
    _explicitLogout = false;
    return true;
  }

  FutureEither<void> logout() async {
    return runTask(() async {
      _explicitLogout = true;
      try {
        final refreshToken = await _readRefreshToken();
        try {
          await _dio.post<Map<String, dynamic>>(
            '/api/auth/logout',
            data: {
              if (refreshToken != null && refreshToken.isNotEmpty)
                'refresh': refreshToken,
            },
          );
        } catch (error, stackTrace) {
          AppLogger.warning(
            'Logout API call failed; clearing local session anyway: $error',
          );
          AppLogger.error('Logout API error details', [error, stackTrace]);
        }
      } finally {
        await _clearSession();
        _authStateController.add(null);
      }
    });
  }

  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    return runTask(() async {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      if (_isTokenExpired(token)) {
        await handleSessionExpired();
        return null;
      }

      return _readStoredUser();
    });
  }

  Future<void> handleSessionExpired() async {
    if (_isHandlingSessionExpiry) return;
    _isHandlingSessionExpiry = true;
    try {
      await _clearSession();
      _authStateController.add(null);
    } finally {
      _isHandlingSessionExpiry = false;
    }
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

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = json['exp'];
      if (exp is! num) return false;

      final expiry =
          DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return false;
    }
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

    final refresh = data['refresh'] ?? data['refresh_token'];
    if (refresh != null && refresh.toString().isNotEmpty) {
      await SecureStorageService.instance.write(
        refreshTokenKey,
        refresh.toString(),
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

  Future<String?> _readRefreshToken() async {
    final result = await SecureStorageService.instance.read(refreshTokenKey);
    return result.fold((_) => null, (value) => value);
  }

  Future<void> _clearSession() async {
    _cachedAccessToken = null;
    await SecureStorageService.instance.deleteAll();
    final cacheResult = await CacheService.instance.clearAll();
    cacheResult.fold(
      (failure) => AppLogger.warning(
        'Failed to clear app caches on session clear: ${failure.message}',
      ),
      (_) {},
    );
  }

  void dispose() {
    _authStateController.close();
  }
}
