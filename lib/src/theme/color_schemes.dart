import 'package:flutter/material.dart';

/// Single place to retheme the app.
///
/// Brand identity comes from the Aajhee wordmark:
/// charcoal letterforms + burgundy j-dot (`#783038`).
/// Change these values and CTAs, deals, favorites, and nav accents
/// update everywhere via [AppPalettes] + [ColorScheme.primary].
abstract final class AppBrandColors {
  AppBrandColors._();

  // ── Primary (CTAs, nav selection, links) ──────────────────────────────────
  // Logo j-dot burgundy — the only chromatic brand color.

  static const Color primary = Color(0xFF783038);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const String primaryHex = '#783038';

  /// Soft blush behind selected chips / primary containers.
  static const Color primaryContainer = Color(0xFFF4E8E9);
  static const Color onPrimaryContainer = Color(0xFF4A1E22);

  // ── Secondary (supporting actions, icons) ─────────────────────────────────
  // Warm slate that sits next to burgundy without competing.

  static const Color secondary = Color(0xFF5C4F51);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFEFE8E8);
  static const Color onSecondaryContainer = Color(0xFF2E2627);

  // ── Surfaces (single light theme) ─────────────────────────────────────────
  // Clean off-white canvas — readable and friendly, not flat black/white.

  static const Color canvas = Color(0xFFF7F5F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1F1B1C);
  static const Color onSurfaceVariant = Color(0xFF6E6466);
  static const Color outline = Color(0xFFD9D0D1);
  static const Color outlineVariant = Color(0xFFECE6E6);

  // ── Deal accent (% Off, sale prices, favorited hearts) ────────────────────
  // Same hue as primary so deals feel on-brand.

  static const Color deal = Color(0xFF783038);
  static const Color onDeal = Color(0xFFFFFFFF);
  static const Color dealContainer = Color(0xFFF4E8E9);
  static const Color onDealContainer = Color(0xFF4A1E22);

  // Legacy aliases kept so older call sites keep compiling.
  static const Color lightPrimary = primary;
  static const Color darkPrimary = primary;
  static const String lightPrimaryHex = primaryHex;
  static const String darkPrimaryHex = primaryHex;
  static const Color lightSecondary = secondary;
  static const Color darkSecondary = secondary;
  static const Color lightDeal = deal;
  static const Color lightOnDeal = onDeal;
  static const Color lightDealContainer = dealContainer;
  static const Color lightOnDealContainer = onDealContainer;
  static const Color darkDeal = deal;
  static const Color darkOnDeal = onDeal;
  static const Color darkDealContainer = dealContainer;
  static const Color darkOnDealContainer = onDealContainer;
}

/// App-specific colors that aren't part of the standard [ColorScheme].
/// Access via `context.appColors`.
///
/// Naming:
/// - [deal] — commerce accent (% Off, prices, favorites)
/// - [warning] — system caution (toasts / snackbars only)
/// - [success] / [info] — status feedback
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.deal,
    required this.onDeal,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    this.dealContainer,
    this.onDealContainer,
    this.successContainer,
    this.onSuccessContainer,
    this.warningContainer,
    this.onWarningContainer,
    this.infoContainer,
    this.onInfoContainer,
  });

  /// Deal / promo accent. Prefer this for badges, sale prices, favorites.
  final Color deal;
  final Color onDeal;
  final Color? dealContainer;
  final Color? onDealContainer;

  /// Alias so UI can read intent: favorited hearts use the deal accent.
  Color get favorite => deal;
  Color get onFavorite => onDeal;

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color? successContainer;
  final Color? onSuccessContainer;
  final Color? warningContainer;
  final Color? onWarningContainer;
  final Color? infoContainer;
  final Color? onInfoContainer;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? deal,
    Color? onDeal,
    Color? dealContainer,
    Color? onDealContainer,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return AppColorsExtension(
      deal: deal ?? this.deal,
      onDeal: onDeal ?? this.onDeal,
      dealContainer: dealContainer ?? this.dealContainer,
      onDealContainer: onDealContainer ?? this.onDealContainer,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      deal: Color.lerp(deal, other.deal, t)!,
      onDeal: Color.lerp(onDeal, other.onDeal, t)!,
      dealContainer: Color.lerp(dealContainer, other.dealContainer, t),
      onDealContainer: Color.lerp(onDealContainer, other.onDealContainer, t),
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t),
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t),
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t),
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t),
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t),
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t),
    );
  }
}

/// Wired palette — single light brand theme.
class AppPalettes {
  AppPalettes._();

  static const brand = AppColorsExtension(
    deal: AppBrandColors.deal,
    onDeal: AppBrandColors.onDeal,
    dealContainer: AppBrandColors.dealContainer,
    onDealContainer: AppBrandColors.onDealContainer,
    success: Color(0xFF2F6B4F),
    onSuccess: Colors.white,
    successContainer: Color(0xFFDCEEE4),
    onSuccessContainer: Color(0xFF163D2A),
    warning: Color(0xFFB07A2E),
    onWarning: Colors.white,
    warningContainer: Color(0xFFF6E9D4),
    onWarningContainer: Color(0xFF4A3414),
    info: Color(0xFF4A6B8A),
    onInfo: Colors.white,
    infoContainer: Color(0xFFE3ECF4),
    onInfoContainer: Color(0xFF1E3348),
  );

  /// Kept for call sites that still reference light/dark names.
  static const light = brand;
  static const dark = brand;
}
