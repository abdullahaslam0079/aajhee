import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aajhee/src/config/app_config.dart';

void main() {
  group('shouldRetryColdStart', () {
    test('retries a GET connection, receive, or connect timeout once', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final error = DioException(
          requestOptions: RequestOptions(path: '/api/products', method: 'GET'),
          type: type,
        );
        expect(
          shouldRetryColdStart(error.requestOptions, error),
          isTrue,
          reason: type.name,
        );
      }
    });

    test('does not retry mutations or a GET that already retried', () {
      for (final method in ['POST', 'PUT', 'PATCH', 'DELETE']) {
        final error = DioException(
          requestOptions: RequestOptions(
            path: '/api/checkout/place',
            method: method,
          ),
          type: DioExceptionType.connectionError,
        );
        expect(
          shouldRetryColdStart(error.requestOptions, error),
          isFalse,
          reason: method,
        );
      }

      final retried = DioException(
        requestOptions: RequestOptions(
          path: '/api/products',
          method: 'GET',
          extra: const {AppConfig.coldStartRetryKey: true},
        ),
        type: DioExceptionType.connectionError,
      );
      expect(shouldRetryColdStart(retried.requestOptions, retried), isFalse);
    });
  });

  group('configureApiClient', () {
    test('retries a GET once after a connection error', () async {
      final adapter = _ScriptedAdapter([
        DioExceptionType.connectionError,
        _ok(),
      ]);
      final dio = _client(adapter);

      final response = await dio.get<dynamic>('/api/products');

      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
      expect(adapter.methods, ['GET', 'GET']);
    });

    test('retries a GET once after a receive timeout', () async {
      final adapter = _ScriptedAdapter([
        DioExceptionType.receiveTimeout,
        _ok(),
      ]);
      final dio = _client(adapter);

      final response = await dio.get<dynamic>('/api/cart');

      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
    });

    test('a second GET failure is not retried again', () async {
      final adapter = _ScriptedAdapter([
        DioExceptionType.connectionError,
        DioExceptionType.connectionError,
      ]);
      final dio = _client(adapter);

      await expectLater(
        dio.get<dynamic>('/api/orders'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 2);
    });

    test('a GET that already opted out is not retried', () async {
      final adapter = _ScriptedAdapter([
        DioExceptionType.connectionTimeout,
      ]);
      final dio = _client(adapter);

      await expectLater(
        dio.get<dynamic>(
          '/',
          options: Options(
            extra: const {AppConfig.coldStartRetryKey: true},
          ),
        ),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1);
    });

    test('mutations are not retried after a connection error', () async {
      for (final method in ['POST', 'PUT', 'PATCH', 'DELETE']) {
        final adapter = _ScriptedAdapter([
          DioExceptionType.connectionError,
        ]);
        final dio = _client(adapter);

        await expectLater(
          dio.request<dynamic>(
            '/api/checkout/place',
            options: Options(method: method),
          ),
          throwsA(isA<DioException>()),
        );
        expect(adapter.calls, 1, reason: method);
      }
    });

    test('a 401 replays once after refresh and does not loop', () async {
      final adapter = _ScriptedAdapter([
        _status(401),
        _ok(),
      ]);
      var refreshes = 0;
      var expiries = 0;
      var token = 'expired';
      final dio = _client(
        adapter,
        readAccessToken: () async => token,
        refreshAccessToken: () async {
          refreshes++;
          token = 'fresh';
          return true;
        },
        onSessionExpired: () async => expiries++,
      );

      final response = await dio.post<dynamic>('/api/checkout/place');

      expect(response.statusCode, 200);
      expect(adapter.calls, 2);
      expect(refreshes, 1);
      expect(expiries, 0);
      expect(adapter.authorizationHeaders, ['Bearer expired', 'Bearer fresh']);
    });

    test('a second 401 expires the session and does not replay again', () async {
      final adapter = _ScriptedAdapter([
        _status(401),
        _status(401),
      ]);
      var refreshes = 0;
      var expiries = 0;
      final dio = _client(
        adapter,
        refreshAccessToken: () async {
          refreshes++;
          return true;
        },
        onSessionExpired: () async => expiries++,
      );

      await expectLater(
        dio.post<dynamic>('/api/orders/abc/cancel'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 2);
      expect(refreshes, 1);
      expect(expiries, 1);
    });

    test('a 401 on token refresh does not refresh again', () async {
      final adapter = _ScriptedAdapter([
        _status(401),
      ]);
      var refreshes = 0;
      final dio = _client(
        adapter,
        refreshAccessToken: () async {
          refreshes++;
          return true;
        },
      );

      await expectLater(
        dio.post<dynamic>(
          '/api/auth/token/refresh',
          options: Options(extra: const {'auth_retry': true}),
        ),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1);
      expect(refreshes, 0);
    });
  });
}

Dio _client(
  _ScriptedAdapter adapter, {
  Future<String?> Function()? readAccessToken,
  Future<bool> Function()? refreshAccessToken,
  Future<void> Function()? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
  dio.httpClientAdapter = adapter;
  configureApiClient(
    dio,
    readAccessToken: readAccessToken ?? () async => 'token',
    refreshAccessToken: refreshAccessToken ?? () async => false,
    onSessionExpired: onSessionExpired ?? () async {},
  );
  return dio;
}

ResponseBody _ok() => _status(200);

ResponseBody _status(int status) {
  return ResponseBody.fromString(
    '{}',
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._steps);

  final List<Object> _steps;
  int calls = 0;
  final methods = <String>[];
  final authorizationHeaders = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    methods.add(options.method);
    authorizationHeaders.add(options.headers['Authorization'] as String?);
    if (_steps.isEmpty) {
      throw StateError('No scripted response for ${options.method} ${options.path}');
    }
    final step = _steps.removeAt(0);
    if (step is DioExceptionType) {
      throw DioException(
        requestOptions: options,
        type: step,
        message: 'scripted ${step.name}',
      );
    }
    return step as ResponseBody;
  }

  @override
  void close({bool force = false}) {}
}
