import 'package:aajhee/src/features/home/data/models/offer_model.dart';
import 'package:aajhee/src/features/home/data/models/usage_limit_type.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_usage_result.dart';

class OfferUsageStatus {
  const OfferUsageStatus({
    required this.redeemedCount,
    required this.maxUses,
    required this.limitType,
    required this.isOfferActive,
    this.isAvailableForUser,
    this.lastRedeemedAt,
    this.periodResetsAt,
  });

  final int redeemedCount;
  final int maxUses;
  final UsageLimitType limitType;
  final bool isOfferActive;
  final bool? isAvailableForUser;
  final DateTime? lastRedeemedAt;
  final DateTime? periodResetsAt;

  factory OfferUsageStatus.fromOffer(OfferModel offer) {
    final limitType = UsageLimitType.fromApi(offer.usageLimitType);
    final maxUses = _maxUses(limitType, offer.usageLimitCount);
    final redeemedCount = offer.userRedemptionCount ?? 0;

    return OfferUsageStatus(
      redeemedCount: redeemedCount,
      maxUses: maxUses,
      limitType: limitType,
      isOfferActive: offer.isActive && offer.isEnabled,
      isAvailableForUser: offer.isAvailableForUser,
      lastRedeemedAt: offer.lastRedeemedAt,
      periodResetsAt: offer.periodResetsAt,
    );
  }

  factory OfferUsageStatus.fromUsageResult(
    OfferModel offer,
    OfferUsageResult usage,
  ) {
    final limitType = UsageLimitType.fromApi(offer.usageLimitType);

    return OfferUsageStatus(
      redeemedCount: usage.redemptionCount,
      maxUses: usage.maxUses,
      limitType: limitType,
      isOfferActive: offer.isActive && offer.isEnabled,
      isAvailableForUser: usage.isAvailableForUser,
      lastRedeemedAt: usage.lastRedeemedAt,
      periodResetsAt: usage.periodResetsAt,
    );
  }

  static int _maxUses(UsageLimitType limitType, int usageLimitCount) {
    return switch (limitType) {
      UsageLimitType.oneTime => 1,
      UsageLimitType.oncePerWeek => 1,
      UsageLimitType.oncePerMonth => 1,
      UsageLimitType.nTimesPerWeek ||
      UsageLimitType.nTimesPerMonth ||
      UsageLimitType.nTimesTotal =>
        usageLimitCount > 0 ? usageLimitCount : 1,
    };
  }

  int get remainingUses => (maxUses - redeemedCount).clamp(0, maxUses);

  bool get isLimitReached => redeemedCount >= maxUses;

  bool get isAvailable {
    if (!isOfferActive) return false;
    if (isAvailableForUser != null) return isAvailableForUser!;
    return !isLimitReached;
  }

  String get periodLabel {
    return switch (limitType) {
      UsageLimitType.oneTime => 'one-time',
      UsageLimitType.oncePerWeek => 'this week',
      UsageLimitType.oncePerMonth => 'this month',
      UsageLimitType.nTimesPerWeek => 'this week',
      UsageLimitType.nTimesPerMonth => 'this month',
      UsageLimitType.nTimesTotal => 'total',
    };
  }

  String get limitDescription {
    return switch (limitType) {
      UsageLimitType.oneTime => 'One-time use',
      UsageLimitType.oncePerWeek => 'Once per week',
      UsageLimitType.oncePerMonth => 'Once per month',
      UsageLimitType.nTimesPerWeek => '$maxUses times per week',
      UsageLimitType.nTimesPerMonth => '$maxUses times per month',
      UsageLimitType.nTimesTotal => '$maxUses times total',
    };
  }

  String get usageSummary =>
      '$redeemedCount of $maxUses redeemed ($periodLabel)';

  String get availabilityLabel {
    if (!isOfferActive) return 'Offer unavailable';
    if (isAvailable) {
      if (remainingUses == maxUses) return 'Available for you';
      return '$remainingUses left · $usageSummary';
    }
    if (periodResetsAt != null && limitType.isPeriodBased) {
      return 'Limit reached · resets ${_formatDate(periodResetsAt!)}';
    }
    return 'Limit reached · $usageSummary';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
