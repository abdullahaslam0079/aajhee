import 'package:flutter/material.dart';

/// Single place to retheme the app.
///
/// Change these values and deal badges, favorites, primary CTAs, and
/// toast accents update everywhere via [AppPalettes] + [ColorScheme.primary].
abstract final class AppBrandColors {
  AppBrandColors._();

  // ── Primary (nav, selected chips, CTAs) ───────────────────────────────────
  // Charcoal. Dark mode uses the same hue, inverted for contrast.

  static const Color lightPrimary = Color(0xFF1A1A1A);
  static const Color darkPrimary = Color(0xFFF2F2F2);
  static const String lightPrimaryHex = '#1A1A1A';
  static const String darkPrimaryHex = '#F2F2F2';

  static const Color lightSecondary = Color(0xFF525252);
  static const Color darkSecondary = Color(0xFFA3A3A3);

  // ── Deal accent (% Off, sale prices, favorited hearts) ────────────────────
  // Wine — same hue in both modes. The only chromatic color.

  static const Color lightDeal = Color(0xFF7A3038);
  static const Color lightOnDeal = Color(0xFFFFFFFF);
  static const Color lightDealContainer = Color(0xFFF4E8E9);
  static const Color lightOnDealContainer = Color(0xFF4A1E22);

  static const Color darkDeal = Color(0xFFD08A90);
  static const Color darkOnDeal = Color(0xFF1A1A1A);
  static const Color darkDealContainer = Color(0xFF3A2428);
  static const Color darkOnDealContainer = Color(0xFFF0D6D8);
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
    success: Color(0xFF3F6B54),
    onSuccess: Colors.white,
    successContainer: Color(0xFFDCE8E1),
    onSuccessContainer: Color(0xFF1F3D2E),
    warning: Color(0xFF8F6A32),
    onWarning: Colors.white,
    warningContainer: Color(0xFFF3E8D4),
    onWarningContainer: Color(0xFF4A3718),
    info: Color(0xFF525252),
    onInfo: Colors.white,
    infoContainer: Color(0xFFECECEC),
    onInfoContainer: Color(0xFF1A1A1A),
  );

  static const dark = AppColorsExtension(
    deal: AppBrandColors.darkDeal,
    onDeal: AppBrandColors.darkOnDeal,
    dealContainer: AppBrandColors.darkDealContainer,
    onDealContainer: AppBrandColors.darkOnDealContainer,
    success: Color(0xFF8FBB9C),
    onSuccess: Color(0xFF102016),
    successContainer: Color(0xFF1C2A22),
    onSuccessContainer: Color(0xFFC5D8CC),
    warning: Color(0xFFC4A36A),
    onWarning: Color(0xFF1C160C),
    warningContainer: Color(0xFF2E2818),
    onWarningContainer: Color(0xFFE8D6B0),
    info: Color(0xFFA3A3A3),
    onInfo: Color(0xFF121212),
    infoContainer: Color(0xFF2A2A2A),
    onInfoContainer: Color(0xFFE8E8E8),
  );
}
