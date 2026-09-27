import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget current = _buildMaterialApp(context);
    current = ScreenUtilWrapper(child: current);
    return current;
  }

  Widget _buildMaterialApp(BuildContext context) {
    final theme = buildAppTheme();
    return MaterialApp.router(
      title: 'Aajhee',
      debugShowCheckedModeBanner: false,
      theme: theme,
      // Single brand theme — light/dark system preference is ignored.
      darkTheme: theme,
      themeMode: ThemeMode.light,
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
