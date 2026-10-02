import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aajhee/src/services/auth_service.dart';
import 'package:aajhee/src/utils/utils.dart';

class AppConfig {
  AppConfig._();
  static late final Dio dio;

  /// Render free-tier cold starts often take 40–90s. Only the wake ping
  /// waits that long. Other calls use [requestTimeout].
  static const Duration coldStartTimeout = Duration(seconds: 90);

  /// Connect, send, and receive budget for normal API calls, including checkout.
  /// One third of [coldStartTimeout]: a warm call can finish, and a failed
  /// checkout ends once instead of waiting through a timeout plus a retry.
  static const Duration requestTimeout = Duration(seconds: 30);

  static const String coldStartRetryKey = 'cold_start_retry';

  static String get baseUrl => _getBaseUrl();

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: requestTimeout,
        sendTimeout: requestTimeout,
        receiveTimeout: requestTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    configureApiClient(
      dio,
      readAccessToken: AuthService.instance.getAccessToken,
      refreshAccessToken: AuthService.instance.refreshAccessToken,
      onSessionExpired: AuthService.instance.handleSessionExpired,
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
          connectTimeout: coldStartTimeout,
          sendTimeout: coldStartTimeout,
          receiveTimeout: coldStartTimeout,
          validateStatus: (_) => true,
          extra: const {coldStartRetryKey: true},
        ),
      );
      AppLogger.info('Backend wake ping completed');
    } catch (error, stackTrace) {
      AppLogger.warning('Backend wake ping failed: $error');
      AppLogger.error('Backend wake ping details', [error, stackTrace]);
    }
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
      fallback: 'https://api.aajhee.com',
    );
  }
}

/// Attaches bearer-token and 401-refresh handling, plus a single cold-start
/// retry for GET requests.
///
/// [refreshAccessToken] and [onSessionExpired] are callbacks so tests can
/// exercise this client without Firebase or secure storage.
void configureApiClient(
  Dio dio, {
  required Future<String?> Function() readAccessToken,
  required Future<bool> Function() refreshAccessToken,
  required Future<void> Function() onSessionExpired,
}) {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (AppConfig._isPublicAuthPath(options.path)) {
          options.headers.remove('Authorization');
          return handler.next(options);
        }

        final token = await readAccessToken();
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
        if (shouldRetryColdStart(error.requestOptions, error)) {
          final options = error.requestOptions;
          options.extra[AppConfig.coldStartRetryKey] = true;
          AppLogger.warning(
            'Cold-start failure on ${options.method} ${options.path}; retrying once…',
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
            !AppConfig._isPublicAuthPath(error.requestOptions.path) &&
            error.requestOptions.extra['auth_retry'] != true) {
          final refreshed = await refreshAccessToken();
          if (refreshed) {
            final options = error.requestOptions;
            options.extra['auth_retry'] = true;
            final token = await readAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            try {
              final response = await dio.fetch<dynamic>(options);
              return handler.resolve(response);
            } catch (retryError) {
              if (retryError is DioException) {
                if (retryError.response?.statusCode == 401) {
                  await onSessionExpired();
                }
                return handler.next(retryError);
              }
              return handler.next(error);
            }
          }
          await onSessionExpired();
        }
        return handler.next(error);
      },
    ),
  );
}

/// Cold-start retry is one extra attempt, and only for GET.
///
/// POST, PUT, PATCH, and DELETE are not retried. A lost response can still
/// mean the server applied the change. This client does not send an
/// idempotency key; the backend would have to enforce one before a retry
/// of checkout could be safe.
bool shouldRetryColdStart(RequestOptions request, DioException error) {
  if (request.method.toUpperCase() != 'GET') return false;
  if (request.extra[AppConfig.coldStartRetryKey] == true) return false;
  return error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError;
}
