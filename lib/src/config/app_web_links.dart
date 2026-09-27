import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

/// Public marketing / web URLs opened from the consumer app.
abstract final class AppWebLinks {
  AppWebLinks._();

  static String get baseUrl {
    final raw = (dotenv.env['WEB_BASE_URL'] ?? 'https://aajhee.com').trim();
    if (raw.isEmpty) return 'https://aajhee.com';
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static String get privacy => '$baseUrl/privacy';
  static String get terms => '$baseUrl/terms';
  static String get help => '$baseUrl/help';
  static const String supportEmail = 'hello@aajhee.com';
  static Uri get supportMailto =>
      Uri(scheme: 'mailto', path: supportEmail, query: 'subject=Aajhee%20Support');

  static Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> openPrivacy() => open(privacy);
  static Future<bool> openTerms() => open(terms);
  static Future<bool> openHelp() => open(help);
  static Future<bool> openContact() =>
      launchUrl(supportMailto, mode: LaunchMode.externalApplication);
}
