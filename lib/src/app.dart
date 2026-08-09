import 'package:goluto/src/features/settings/presentation/providers/theme_preferences_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      themePreferencesProvider.select((state) => state.themeMode),
    );

    Widget current = _buildMaterialApp(context, themeMode);
    current = ScreenUtilWrapper(child: current);
    return current;
  }

  Widget _buildMaterialApp(BuildContext context, ThemeMode themeMode) {
    return MaterialApp.router(
      title: 'GoLuto',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: AppBrandColors.lightPrimaryHex),
      darkTheme: buildDarkTheme(primaryColorHex: AppBrandColors.darkPrimaryHex),
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        final textTheme = Theme.of(context).textTheme;
        Widget current = DefaultTextStyle(
          style: textTheme.bodyMedium ??
              const TextStyle(fontFamily: AppFonts.primary),
          child: child!,
        );
        current = SkeletonWrapper(child: current);
        current = SessionListenerWrapper(child: current);
        return current;
      },
    );
  }
}
