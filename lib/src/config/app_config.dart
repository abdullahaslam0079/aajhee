import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:goluto/src/services/auth_service.dart';
import 'package:goluto/src/utils/utils.dart';

class AppConfig {
  AppConfig._();
  static late final Dio dio;

  /// Render free-tier cold starts often take 40–90s; keep timeouts above that.
  static const Duration connectTimeout = Duration(seconds: 90);
  static const Duration receiveTimeout = Duration(seconds: 90);

  static const String _coldStartRetryKey = 'cold_start_retry';

  static String get baseUrl => _getBaseUrl();

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_isPublicAuthPath(options.path)) {
            options.headers.remove('Authorization');
            return handler.next(options);
          }

          final token = await AuthService.instance.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            AppLogger.warning(
              'No auth token available for protected request: ${options.path}',
            );
          }
          return handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) async {
          if (_shouldRetryColdStart(error)) {
            final options = error.requestOptions;
            options.extra[_coldStartRetryKey] = true;
            AppLogger.warning(
              'Cold-start timeout on ${options.path}; retrying once…',
            );
            try {
              final response = await dio.fetch<dynamic>(options);
              return handler.resolve(response);
            } catch (retryError) {
              if (retryError is DioException) {
                return handler.next(retryError);
              }
              return handler.next(error);
            }
          }

          if (error.response?.statusCode == 401 &&
              !_isPublicAuthPath(error.requestOptions.path)) {
            await AuthService.instance.handleSessionExpired();
          }
          return handler.next(error);
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final hasAuth = options.headers['Authorization'] != null;
          AppLogger.info(
            '🌐 [DIO] REQUEST[${options.method}] => PATH: ${options.path} (auth: $hasAuth)',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info('✅ [DIO] RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          AppLogger.error(
            '❌ [DIO] ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path} body: ${e.response?.data}',
          );
          return handler.next(e);
        },
      ),
    );

    await AuthService.instance.restoreAccessToken();

    // Kick Render awake in the background so the first real API call is warmer.
    unawaited(wakeBackend());
  }

  /// Lightweight ping so a sleeping Render instance starts booting early.
  /// Any HTTP response (including 404) means the process is up.
  static Future<void> wakeBackend() async {
    try {
      AppLogger.info('Waking backend at $baseUrl …');
      await dio.get<dynamic>(
        '/',
        options: Options(
          receiveTimeout: receiveTimeout,
          sendTimeout: connectTimeout,
          validateStatus: (_) => true,
          extra: {_coldStartRetryKey: true},
        ),
      );
      AppLogger.info('Backend wake ping completed');
    } catch (error, stackTrace) {
      AppLogger.warning('Backend wake ping failed: $error');
      AppLogger.error('Backend wake ping details', [error, stackTrace]);
    }
  }

  static bool _shouldRetryColdStart(DioException error) {
    if (error.requestOptions.extra[_coldStartRetryKey] == true) {
      return false;
    }
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;
  }

  static bool _isPublicAuthPath(String path) {
    return path.contains('/api/auth/token') ||
        path.contains('/api/auth/register') ||
        path.contains('/api/auth/phone') ||
        path.contains('/api/auth/firebase') ||
        path.contains('/api/auth/password/');
  }

  static String _getBaseUrl() {
    return dotenv.get(
      'API_BASE_URL',
      fallback: 'https://api.goluto.de',
    );
  }
}
