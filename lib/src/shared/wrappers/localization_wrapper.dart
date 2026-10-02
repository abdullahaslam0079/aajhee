import '../../imports/core_imports.dart';
import 'package:easy_localization/easy_localization.dart';

/// A wrapper to initialize [EasyLocalization] with supported locales.
class LocalizationWrapper extends StatelessWidget {
  final Widget child;

  const LocalizationWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: child,
    );
  }
}
