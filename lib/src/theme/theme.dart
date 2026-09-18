import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'text_theme.dart';
import 'color_schemes.dart';
import 'app_borders.dart';
import 'app_fonts.dart';

Color _colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  return Color(int.parse('ff$cleaned', radix: 16));
}

/// Soft canvas for home feed and shell backgrounds.
/// Light: warm grey. Dark: true charcoal. Neutral — no blue cast.
const Color kHomeCanvasColor = Color(0xFFF5F5F5);
const Color kHomeCanvasColorDark = Color(0xFF121212);

Color homeCanvasOf(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? kHomeCanvasColorDark
      : kHomeCanvasColor;
}

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

ThemeData _buildTheme(ColorScheme colorScheme, AppColorsExtension customColors) {
  final textTheme = buildTextTheme();
  
  return ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.primary,
    primaryColor: colorScheme.primary,
    colorScheme: colorScheme,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    extensions: [
      customColors,
      AppDesignTokens.fallback,
    ],
    
    // --- Basic Elements ---
    scaffoldBackgroundColor: colorScheme.surface,
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    iconTheme: IconThemeData(
      color: colorScheme.onSurface,
      size: 24,
    ),
    
    // --- Widget Themes ---

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const RoundedRectangleBorder(borderRadius: AppBorders.button),
        elevation: 0,
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return 2;
          return 0;
        }),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const RoundedRectangleBorder(borderRadius: AppBorders.button),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: const RoundedRectangleBorder(borderRadius: AppBorders.button),
        side: BorderSide(color: colorScheme.outline, width: 1.5),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(88, 40),
        shape: const RoundedRectangleBorder(borderRadius: AppBorders.sm),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      elevation: AppDesignTokens.fallback.cardElevation,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        borderRadius: AppBorders.card,
      ),
      color: colorScheme.surfaceContainerLowest,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppBorders.input,
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorders.input,
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorders.input,
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorders.input,
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppBorders.input,
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      floatingLabelStyle: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
      labelStyle: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
    ),

    // Navigation Bar Theme
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainerLowest,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          );
        }
        return textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant);
      }),
    ),

    // Navigation Rail Theme
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      labelType: NavigationRailLabelType.all,
      unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
      selectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
    ),

    // Tab Bar Theme
    tabBarTheme: TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: textTheme.titleSmall,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 2,
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.lg),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
      side: BorderSide(color: colorScheme.outlineVariant),
      backgroundColor: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: textTheme.labelMedium,
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
      visualDensity: VisualDensity.comfortable,
      titleTextStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.xs),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primaryContainer;
        return colorScheme.surfaceContainerHighest;
      }),
    ),

    // SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
      elevation: 4,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.dialog),
      elevation: 0,
      backgroundColor: colorScheme.surfaceContainerLowest,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      showDragHandle: true,
      elevation: 0,
      backgroundColor: colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: AppBorders.bottomSheet,
      ),
    ),

    // Search Bar Theme
    searchBarTheme: SearchBarThemeData(
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainerLow),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(borderRadius: AppBorders.input),
      ),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
      hintStyle: WidgetStateProperty.all(textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
    ),

    // Badge Theme
    badgeTheme: BadgeThemeData(
      backgroundColor: colorScheme.error,
      textColor: colorScheme.onError,
      textStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
    ),

    // Segmented Button Theme
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: colorScheme.secondaryContainer,
        selectedForegroundColor: colorScheme.onSecondaryContainer,
        side: BorderSide(color: colorScheme.outline),
      ),
    ),

    // Tooltip Theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface.withValues(alpha: 0.92),
        borderRadius: AppBorders.sm,
      ),
      textStyle: textTheme.labelSmall?.copyWith(color: colorScheme.onInverseSurface),
    ),
  );
}

ThemeData buildLightTheme({required String primaryColorHex}) {
  final accent = _colorFromHex(
    primaryColorHex.isNotEmpty ? primaryColorHex : AppBrandColors.lightPrimaryHex,
  );
  final colorScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.light,
  ).copyWith(
    primary: accent,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFECECEC),
    onPrimaryContainer: const Color(0xFF1A1A1A),
    secondary: AppBrandColors.lightSecondary,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFE8E8E8),
    onSecondaryContainer: const Color(0xFF1A1A1A),
    surface: kHomeCanvasColor,
    onSurface: const Color(0xFF1A1A1A),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Colors.white,
    surfaceContainer: const Color(0xFFF5F5F5),
    surfaceContainerHigh: const Color(0xFFECECEC),
    surfaceContainerHighest: const Color(0xFFE0E0E0),
    onSurfaceVariant: const Color(0xFF6B6B6B),
    outline: const Color(0xFFD4D4D4),
    outlineVariant: const Color(0xFFE5E5E5),
    shadow: Colors.black.withValues(alpha: 0.12),
    scrim: Colors.black.withValues(alpha: 0.46),
    inverseSurface: const Color(0xFF1A1A1A),
    onInverseSurface: const Color(0xFFF5F5F5),
    inversePrimary: const Color(0xFFF2F2F2),
  );
  return _buildTheme(colorScheme, AppPalettes.light);
}

ThemeData buildDarkTheme({required String primaryColorHex}) {
  final accent = _colorFromHex(
    primaryColorHex.isNotEmpty ? primaryColorHex : AppBrandColors.darkPrimaryHex,
  );
  final colorScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
  ).copyWith(
    primary: accent,
    onPrimary: const Color(0xFF1A1A1A),
    primaryContainer: const Color(0xFF2A2A2A),
    onPrimaryContainer: const Color(0xFFF2F2F2),
    secondary: AppBrandColors.darkSecondary,
    onSecondary: const Color(0xFF121212),
    secondaryContainer: const Color(0xFF2A2A2A),
    onSecondaryContainer: const Color(0xFFE8E8E8),
    surface: kHomeCanvasColorDark,
    onSurface: const Color(0xFFF2F2F2),
    surfaceContainerLowest: const Color(0xFF1C1C1C),
    surfaceContainerLow: const Color(0xFF1C1C1C),
    surfaceContainer: const Color(0xFF242424),
    surfaceContainerHigh: const Color(0xFF2E2E2E),
    surfaceContainerHighest: const Color(0xFF3A3A3A),
    onSurfaceVariant: const Color(0xFFA3A3A3),
    outline: const Color(0xFF4A4A4A),
    outlineVariant: const Color(0xFF2E2E2E),
    shadow: Colors.black.withValues(alpha: 0.55),
    scrim: Colors.black.withValues(alpha: 0.72),
    inverseSurface: const Color(0xFFF2F2F2),
    onInverseSurface: const Color(0xFF121212),
    inversePrimary: const Color(0xFF1A1A1A),
  );
  return _buildTheme(colorScheme, AppPalettes.dark);
}

CupertinoThemeData buildCupertinoTheme({required String primaryColorHex}) {
  final seed = _colorFromHex(
    primaryColorHex.isNotEmpty ? primaryColorHex : AppBrandColors.lightPrimaryHex,
  );
  const fontFamily = AppFonts.primary;

  return CupertinoThemeData(
    applyThemeToAll: true,
    primaryColor: seed,
    primaryContrastingColor: CupertinoColors.white,
    brightness: null, // Allow system-wide dark mode support
    scaffoldBackgroundColor: CupertinoColors.systemBackground,
    barBackgroundColor: CupertinoColors.systemGrey6,
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
