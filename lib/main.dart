import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'src/app.dart';
import 'src/config/app_config.dart';
import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/services/push_notification_service.dart';
import 'src/services/storage_service.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();
  await _loadEnv();

  await AppConfig.init();
  await StorageService.instance.init();
  // Register the FCM background handler as early as possible (before runApp).
  PushNotificationService.instance.registerBackgroundHandler();
  await PushNotificationService.instance.init();

  final sentryDsn = dotenv.get('SENTRY_DSN', fallback: '').trim();
  const app = LocalizationWrapper(
    child: StateWrapper(
      child: App(),
    ),
  );

  if (sentryDsn.isEmpty) {
    runApp(app);
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.environment =
          dotenv.get('SENTRY_ENVIRONMENT', fallback: 'production');
      options.tracesSampleRate = double.tryParse(
            dotenv.get('SENTRY_TRACES_SAMPLE_RATE', fallback: '0.1'),
          ) ??
          0.1;
      options.sendDefaultPii = false;
    },
    appRunner: () => runApp(app),
  );
}

/// Loads committed defaults, then overlays a local gitignored `.env` in debug.
Future<void> _loadEnv() async {
  await dotenv.load(fileName: '.env.example');
  if (!kDebugMode) return;
  try {
    final file = File('.env');
    if (!file.existsSync()) return;
    dotenv.env.addAll(_parseEnvFile(file.readAsStringSync()));
  } catch (_) {
    // Keep example values when the local override is missing or unreadable.
  }
}

Map<String, String> _parseEnvFile(String raw) {
  final values = <String, String>{};
  for (final line in raw.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final separator = trimmed.indexOf('=');
    if (separator <= 0) continue;
    final key = trimmed.substring(0, separator).trim();
    final value = trimmed.substring(separator + 1).trim();
    if (key.isEmpty) continue;
    values[key] = value;
  }
  return values;
}
