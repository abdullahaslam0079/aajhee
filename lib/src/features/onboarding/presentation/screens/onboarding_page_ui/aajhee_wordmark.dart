part of 'package:aajhee/src/features/onboarding/presentation/screens/onboarding_page.dart';

class _AajheeWordmark extends StatelessWidget {
  const _AajheeWordmark({
    required this.textTheme,
    required this.colorScheme,
  });

  // Kept for call-site consistency; wordmark is an image asset.
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark ? AppAssets.logoOnDark : AppAssets.logo,
      height: 28.h,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
