import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'text_theme.dart';
import 'color_schemes.dart';
import 'app_borders.dart';
import 'app_fonts.dart';

part 'component_themes.dart';

Color _colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  return Color(int.parse('ff$cleaned', radix: 16));
}

/// Soft canvas for home feed and shell backgrounds (single light brand theme).
const Color kHomeCanvasColor = AppBrandColors.canvas;

Color homeCanvasOf(BuildContext context) => kHomeCanvasColor;

/// Custom theme extension for spacing and other design tokens
class AppDesignTokens extends ThemeExtension<AppDesignTokens> {
  const AppDesignTokens({
    required this.paddingSmall,
    required this.paddingMedium,
    required this.paddingLarge,
    required this.borderRadiusSmall,
    required this.borderRadiusMedium,
    required this.borderRadiusLarge,
    required this.cardElevation,
  });

  final double paddingSmall;
  final double paddingMedium;
  final double paddingLarge;
  final double borderRadiusSmall;
  final double borderRadiusMedium;
  final double borderRadiusLarge;
  final double cardElevation;

  static const fallback = AppDesignTokens(
    paddingSmall: 8,
    paddingMedium: 16,
    paddingLarge: 24,
    borderRadiusSmall: 8,
    borderRadiusMedium: 12,
    borderRadiusLarge: 16,
    cardElevation: 0,
  );

  @override
  ThemeExtension<AppDesignTokens> copyWith({
    double? paddingSmall,
    double? paddingMedium,
    double? paddingLarge,
    double? borderRadiusSmall,
    double? borderRadiusMedium,
    double? borderRadiusLarge,
    double? cardElevation,
  }) {
    return AppDesignTokens(
      paddingSmall: paddingSmall ?? this.paddingSmall,
      paddingMedium: paddingMedium ?? this.paddingMedium,
      paddingLarge: paddingLarge ?? this.paddingLarge,
      borderRadiusSmall: borderRadiusSmall ?? this.borderRadiusSmall,
      borderRadiusMedium: borderRadiusMedium ?? this.borderRadiusMedium,
      borderRadiusLarge: borderRadiusLarge ?? this.borderRadiusLarge,
      cardElevation: cardElevation ?? this.cardElevation,
    );
  }

  @override
  ThemeExtension<AppDesignTokens> lerp(
    covariant ThemeExtension<AppDesignTokens>? other,
    double t,
  ) {
    if (other is! AppDesignTokens) return this;
    return AppDesignTokens(
      paddingSmall: lerpDouble(paddingSmall, other.paddingSmall, t)!,
      paddingMedium: lerpDouble(paddingMedium, other.paddingMedium, t)!,
      paddingLarge: lerpDouble(paddingLarge, other.paddingLarge, t)!,
      borderRadiusSmall: lerpDouble(borderRadiusSmall, other.borderRadiusSmall, t)!,
      borderRadiusMedium: lerpDouble(borderRadiusMedium, other.borderRadiusMedium, t)!,
      borderRadiusLarge: lerpDouble(borderRadiusLarge, other.borderRadiusLarge, t)!,
      cardElevation: lerpDouble(cardElevation, other.cardElevation, t)!,
    );
  }

  static double? lerpDouble(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}


/// The one Aajhee brand theme — light canvas + logo burgundy primary + Inter.
ThemeData buildAppTheme({String primaryColorHex = AppBrandColors.primaryHex}) {
  final accent = _colorFromHex(
    primaryColorHex.isNotEmpty ? primaryColorHex : AppBrandColors.primaryHex,
  );
  final colorScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.light,
  ).copyWith(
    primary: accent,
    onPrimary: AppBrandColors.onPrimary,
    primaryContainer: AppBrandColors.primaryContainer,
    onPrimaryContainer: AppBrandColors.onPrimaryContainer,
    secondary: AppBrandColors.secondary,
    onSecondary: AppBrandColors.onSecondary,
    secondaryContainer: AppBrandColors.secondaryContainer,
    onSecondaryContainer: AppBrandColors.onSecondaryContainer,
    tertiary: const Color(0xFF8A5A3A),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFF3E6DC),
    onTertiaryContainer: const Color(0xFF3D2618),
    error: const Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: const Color(0xFFF9DEDC),
    onErrorContainer: const Color(0xFF410E0B),
    surface: AppBrandColors.canvas,
    onSurface: AppBrandColors.onSurface,
    surfaceContainerLowest: AppBrandColors.surface,
    surfaceContainerLow: const Color(0xFFFCFBFB),
    surfaceContainer: const Color(0xFFF3F0EF),
    surfaceContainerHigh: const Color(0xFFECE7E7),
    surfaceContainerHighest: const Color(0xFFE5DFDF),
    onSurfaceVariant: AppBrandColors.onSurfaceVariant,
    outline: AppBrandColors.outline,
    outlineVariant: AppBrandColors.outlineVariant,
    shadow: Colors.black.withValues(alpha: 0.1),
    scrim: Colors.black.withValues(alpha: 0.42),
    inverseSurface: const Color(0xFF322B2C),
    onInverseSurface: const Color(0xFFF7F5F4),
    inversePrimary: const Color(0xFFE8B4B8),
  );
  return _buildTheme(colorScheme, AppPalettes.brand);
}

/// @deprecated Use [buildAppTheme]. Kept for older call sites.
ThemeData buildLightTheme({required String primaryColorHex}) =>
    buildAppTheme(primaryColorHex: primaryColorHex);

/// Single theme app — dark mode is intentionally the same brand theme.
ThemeData buildDarkTheme({required String primaryColorHex}) =>
    buildAppTheme(primaryColorHex: primaryColorHex);

CupertinoThemeData buildCupertinoTheme({
  String primaryColorHex = AppBrandColors.primaryHex,
}) {
  final seed = _colorFromHex(
    primaryColorHex.isNotEmpty ? primaryColorHex : AppBrandColors.primaryHex,
  );
  const fontFamily = AppFonts.primary;

  return CupertinoThemeData(
    applyThemeToAll: true,
    primaryColor: seed,
    primaryContrastingColor: CupertinoColors.white,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7F5F4),
    barBackgroundColor: CupertinoColors.white,
    textTheme: CupertinoTextThemeData(
      primaryColor: seed,
      textStyle: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        letterSpacing: -0.01,
      ),
      actionTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: seed,
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),
      navTitleTextStyle: const TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 17,
        letterSpacing: -0.01,
      ),
      navLargeTitleTextStyle: const TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 34,
        letterSpacing: -0.02,
      ),
      tabLabelTextStyle: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      pickerTextStyle: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 21,
        letterSpacing: -0.01,
      ),
      dateTimePickerTextStyle: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 21,
        letterSpacing: -0.01,
      ),
    ),
  );
}
