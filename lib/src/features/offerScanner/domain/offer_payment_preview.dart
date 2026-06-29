import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/utils/api_value_parsers.dart';

class OfferPaymentPreview {
  const OfferPaymentPreview({
    required this.offerType,
    required this.discountPercent,
    required this.requiresBillAmount,
    this.itemName,
    this.originalAmount,
    this.discountAmount,
    this.amountToPay,
    this.billAmount,
    this.summary,
  });

  final OfferType offerType;
  final double discountPercent;
  final bool requiresBillAmount;
  final String? itemName;
  final double? originalAmount;
  final double? discountAmount;
  final double? amountToPay;
  final double? billAmount;
  final String? summary;

  bool get isComplete => amountToPay != null;

  factory OfferPaymentPreview.fromJson(Map<String, dynamic> json) {
    return OfferPaymentPreview(
      offerType: OfferType.fromApi(parseApiString(json['offer_type']) ?? ''),
      discountPercent: parseApiDouble(json['discount_percent']),
      requiresBillAmount: json['requires_bill_amount'] as bool? ?? false,
      itemName: parseApiString(json['item_name']),
      originalAmount: parseApiNullableDouble(json['original_amount']),
      discountAmount: parseApiNullableDouble(json['discount_amount']),
      amountToPay: parseApiNullableDouble(json['amount_to_pay']),
      billAmount: parseApiNullableDouble(json['bill_amount']),
      summary: parseApiString(json['summary']),
    );
  }
}
