import 'package:aajhee/src/features/home/data/models/offer_model.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_payment_preview.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_usage_result.dart';
import 'package:aajhee/src/utils/api_value_parsers.dart';

class OfferQrBranch {
  const OfferQrBranch({
    required this.id,
    required this.name,
    required this.businessName,
    required this.formattedAddress,
  });

  final int id;
  final String name;
  final String businessName;
  final String formattedAddress;

  factory OfferQrBranch.fromJson(Map<String, dynamic> json) {
    return OfferQrBranch(
      id: parseApiInt(json['id']),
      name: parseApiString(json['name']) ?? '',
      businessName: parseApiString(json['business_name']) ?? '',
      formattedAddress: parseApiString(json['formatted_address']) ?? '',
    );
  }
}

class OfferByQrResult {
  const OfferByQrResult({
    required this.offer,
    required this.branch,
    required this.payment,
    required this.canAvail,
    this.usage,
  });

  final OfferModel offer;
  final OfferQrBranch branch;
  final OfferPaymentPreview payment;
  final bool canAvail;
  final OfferUsageResult? usage;

  factory OfferByQrResult.fromJson(Map<String, dynamic> json) {
    final usageJson = json.containsKey('user_redemption_count')
        ? json
        : null;

    return OfferByQrResult(
      offer: OfferModel.fromQrSummary(
        json['offer'] as Map<String, dynamic>? ?? const {},
      ),
      branch: OfferQrBranch.fromJson(
        json['branch'] as Map<String, dynamic>? ?? const {},
      ),
      payment: OfferPaymentPreview.fromJson(
        json['payment'] as Map<String, dynamic>? ?? const {},
      ),
      canAvail: json['can_avail'] as bool? ?? false,
      usage: usageJson != null ? OfferUsageResult.fromJson(usageJson) : null,
    );
  }
}
