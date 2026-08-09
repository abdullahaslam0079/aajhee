import 'package:flutter/material.dart';

/// Single place to retheme the app.
///
/// Change these values and deal badges, favorites, primary CTAs, and
/// toast accents update everywhere via [AppPalettes] + [ColorScheme.primary].
abstract final class AppBrandColors {
  AppBrandColors._();

  // ── Primary (nav, selected chips, CTAs, distance) ─────────────────────────

  static const String lightPrimaryHex = '#1F1F21';
  static const String darkPrimaryHex = '#E8E8ED';

  // ── Deal accent (% Off, sale prices, favorited hearts) ────────────────────
  // Deep wine — calm against charcoal greys. Swap this family to retheme deals.

  static const Color lightDeal = Color(0xFF7A3E3E);
  static const Color lightOnDeal = Color(0xFFFFFFFF);
  static const Color lightDealContainer = Color(0xFFF0E4E4);
  static const Color lightOnDealContainer = Color(0xFF4A2424);

  static const Color darkDeal = Color(0xFFC45F5F);
  static const Color darkOnDeal = Color(0xFFFFFFFF);
  static const Color darkDealContainer = Color(0xFF3F2528);
  static const Color darkOnDealContainer = Color(0xFFF5DADA);
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

/// Wired palettes — values come from [AppBrandColors] so one edit rethemes.
class AppPalettes {
  AppPalettes._();

  static const light = AppColorsExtension(
    deal: AppBrandColors.lightDeal,
    onDeal: AppBrandColors.lightOnDeal,
    dealContainer: AppBrandColors.lightDealContainer,
    onDealContainer: AppBrandColors.lightOnDealContainer,
    success: Color(0xFF2E7D32),
    onSuccess: Colors.white,
    successContainer: Color(0xFFA5D6A7),
    onSuccessContainer: Color(0xFF1B5E20),
    // System warning only (toasts) — not for deals.
    warning: Color(0xFFB45309),
    onWarning: Colors.white,
    warningContainer: Color(0xFFFDE68A),
    onWarningContainer: Color(0xFF78350F),
    info: Color(0xFF0288D1),
    onInfo: Colors.white,
    infoContainer: Color(0xFF81D4FA),
    onInfoContainer: Color(0xFF01579B),
  );

  static const dark = AppColorsExtension(
    deal: AppBrandColors.darkDeal,
    onDeal: AppBrandColors.darkOnDeal,
    dealContainer: AppBrandColors.darkDealContainer,
    onDealContainer: AppBrandColors.darkOnDealContainer,
    success: Color(0xFF81C784),
    onSuccess: Color(0xFF003300),
    successContainer: Color(0xFF1B5E20),
    onSuccessContainer: Color(0xFFA5D6A7),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF451A03),
    warningContainer: Color(0xFF78350F),
    onWarningContainer: Color(0xFFFDE68A),
    info: Color(0xFF4FC3F7),
    onInfo: Color(0xFF01579B),
    infoContainer: Color(0xFF0277BD),
    onInfoContainer: Color(0xFFE1F5FE),
  );
}
