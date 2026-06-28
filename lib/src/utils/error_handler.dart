import 'package:dio/dio.dart';

class AppErrorHandler {
  static String format(dynamic error) {
    if (error is String) return error;

    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        return 'Your session has expired. Please log in again.';
      }

      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }

        final detail = data['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }

        final error = data['error'];
        if (error is String && error.isNotEmpty) {
          return error;
        }

        final errors = data['errors'];
        if (errors is Map) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
          }
        }
      }

      return error.message ?? 'An unexpected error occurred';
    }

    try {
      if (error?.message != null) return error.message;
      if (error?.toString() != null) return error.toString();
    } catch (_) {}

    return 'An unexpected error occurred';
  }
}
