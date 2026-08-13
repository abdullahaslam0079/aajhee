import 'package:dio/dio.dart';

class AppErrorHandler {
  static String format(dynamic error) {
    if (error is String) return error;

    if (error is DioException) {
      final bodyMessage = _extractBodyMessage(error.response?.data);
      final statusCode = error.response?.statusCode;

      // Prefer the API message. Only fall back to "session expired" when the
      // backend did not explain a 401 (e.g. expired JWT on a protected route).
      if (statusCode == 401) {
        return bodyMessage ?? 'Your session has expired. Please log in again.';
      }

      if (bodyMessage != null) return bodyMessage;

      return error.message ?? 'An unexpected error occurred';
    }

    try {
      if (error?.message != null) return error.message;
      if (error?.toString() != null) return error.toString();
    } catch (_) {}

    return 'An unexpected error occurred';
  }

  static String? _extractBodyMessage(dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);

    final message = map['message'];
    if (message is String && message.isNotEmpty) return message;

    final detail = map['detail'];
    if (detail is String && detail.isNotEmpty) return detail;

    final error = map['error'];
    if (error is String && error.isNotEmpty) return error;

    final errors = map['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }
}
