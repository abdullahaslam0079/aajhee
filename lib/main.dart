import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/app.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await AppConfig.init();
  await StorageService.instance.init();
  await PushNotificationService.instance.init();

  final sentryDsn = dotenv.get('SENTRY_DSN', fallback: '').trim();
  if (sentryDsn.isEmpty) {
    runApp(
      const LocalizationWrapper(
        child: StateWrapper(
          child: App(),
        ),
      ),
    );
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
    appRunner: () => runApp(
      const LocalizationWrapper(
        child: StateWrapper(
          child: App(),
        ),
      ),
    ),
  );
}
