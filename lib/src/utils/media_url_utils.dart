import 'package:aajhee/src/config/app_config.dart';

String? resolveMediaUrl(String? url) {
  if (url == null || url.trim().isEmpty) return null;

  final trimmed = url.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$base$path';
}

bool isAvifUrl(String url) {
  final normalized = url.split('?').first.toLowerCase();
  return normalized.endsWith('.avif');
}
