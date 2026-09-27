import 'package:aajhee/src/utils/api_value_parsers.dart';
import 'package:aajhee/src/utils/media_url_utils.dart';

/// Discount highlight attached to a map branch (API: highest_discount_offer).
class BranchDiscountSummary {
  const BranchDiscountSummary({
    required this.id,
    required this.title,
    required this.discountPercent,
    this.imageUrl,
  });

  final int id;
  final String title;
  final double discountPercent;
  final String? imageUrl;

  factory BranchDiscountSummary.fromJson(Map<String, dynamic> json) {
    return BranchDiscountSummary(
      id: parseApiInt(json['id']),
      title: parseApiString(json['title']) ?? '',
      discountPercent: parseApiDouble(json['discount_percent']),
      imageUrl: resolveMediaUrl(
        parseApiString(
          json['image_url'] ?? json['image'] ?? json['cover_image_url'],
        ),
      ),
    );
  }
}
