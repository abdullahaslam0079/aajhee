import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:goluto/src/services/auth_service.dart';
import 'package:goluto/src/utils/utils.dart';

class AppConfig {
  AppConfig._();
  static late final Dio dio;

  static String get baseUrl => _getBaseUrl();

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
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
          AppLogger.error('❌ [DIO] ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );

    await AuthService.instance.restoreAccessToken();
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
      fallback: 'https://goluto-backend.onrender.com',
    );
  }
}
