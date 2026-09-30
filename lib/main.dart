import 'package:sentry_flutter/sentry_flutter.dart';

import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/app.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

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
