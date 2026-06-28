class OfferUsageResult {
  const OfferUsageResult({
    required this.offerId,
    required this.redemptionCount,
    required this.remainingUses,
    required this.maxUses,
    required this.isAvailableForUser,
    this.lastRedeemedAt,
    this.periodResetsAt,
    this.message,
  });

  final int offerId;
  final int redemptionCount;
  final int remainingUses;
  final int maxUses;
  final bool isAvailableForUser;
  final DateTime? lastRedeemedAt;
  final DateTime? periodResetsAt;
  final String? message;

  factory OfferUsageResult.fromJson(Map<String, dynamic> json) {
    return OfferUsageResult(
      offerId: (json['offer_id'] as num?)?.toInt() ?? 0,
      redemptionCount: (json['user_redemption_count'] as num?)?.toInt() ?? 0,
      remainingUses: (json['user_remaining_uses'] as num?)?.toInt() ?? 0,
      maxUses: (json['max_uses'] as num?)?.toInt() ?? 1,
      isAvailableForUser: json['is_available_for_user'] as bool? ?? false,
      lastRedeemedAt: _parseDate(json['last_redeemed_at']),
      periodResetsAt: _parseDate(json['period_resets_at']),
      message: json['message'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) return null;
    return DateTime.tryParse(value.toString());
  }
}
