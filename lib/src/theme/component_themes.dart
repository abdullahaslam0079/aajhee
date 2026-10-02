part of 'theme.dart';

ThemeData _buildTheme(
    ColorScheme colorScheme, AppColorsExtension customColors) {
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
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      circularTrackColor: colorScheme.primary.withValues(alpha: 0.15),
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
      floatingLabelStyle:
          textTheme.labelMedium?.copyWith(color: colorScheme.primary),
      labelStyle:
          textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
    ),

    // Navigation Bar Theme
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainerLowest,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          );
        }
        return textTheme.labelSmall
            ?.copyWith(color: colorScheme.onSurfaceVariant);
      }),
    ),

    // Navigation Rail Theme
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      labelType: NavigationRailLabelType.all,
      unselectedLabelTextStyle:
          textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
      selectedLabelTextStyle: textTheme.labelSmall
          ?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
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
    // Always set textColor + title color: ListTileThemeData.titleTextStyle without a
    // color overrides M3 defaults, and M3 ListTile has no default textColor — titles
    // then inherit nothing useful and can render invisible on light sheets.
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
      visualDensity: VisualDensity.comfortable,
      textColor: colorScheme.onSurface,
      iconColor: colorScheme.onSurface,
      titleTextStyle: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    ),

    // Checkbox Theme
    checkboxTheme: const CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: AppBorders.xs),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primaryContainer;
        }
        return colorScheme.surfaceContainerHighest;
      }),
    ),

    // SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
      elevation: 4,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle:
          textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.dialog),
      elevation: 0,
      backgroundColor: colorScheme.surfaceContainerLowest,
      titleTextStyle:
          textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
      padding:
          WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
      hintStyle: WidgetStateProperty.all(
          textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
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
      textStyle:
          textTheme.labelSmall?.copyWith(color: colorScheme.onInverseSurface),
    ),
  );
}
