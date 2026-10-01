import 'package:aajhee/src/utils/api_value_parsers.dart';
import 'package:aajhee/src/utils/media_url_utils.dart';

/// Slim product preview embedded on map/store branch payloads.
class BranchTopProductModel {
  const BranchTopProductModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.basePrice,
    this.salePrice,
    this.discountPercent,
    this.effectivePrice,
    this.effectiveDiscountPercent,
    this.hasDiscount = false,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final double basePrice;
  final double? salePrice;
  final double? discountPercent;
  final double? effectivePrice;
  final double? effectiveDiscountPercent;
  final bool hasDiscount;

  factory BranchTopProductModel.fromJson(Map<String, dynamic> json) {
    return BranchTopProductModel(
      id: parseApiInt(json['id']),
      name: parseApiString(json['name']) ?? '',
      imageUrl: resolveMediaUrl(
        parseApiString(
          json['image_url'] ??
              json['thumbnail_url'] ??
              json['cover_image_url'] ??
              json['image'],
        ),
      ),
      basePrice: parseApiDouble(json['base_price'] ?? json['price']),
      salePrice: parseApiNullableDouble(
        json['sale_price'] ?? json['discounted_price'],
      ),
      discountPercent: parseApiNullableDouble(
        json['discount_percent'] ?? json['discount_percentage'],
      ),
      effectivePrice: parseApiNullableDouble(json['effective_price']),
      effectiveDiscountPercent: parseApiNullableDouble(
        json['effective_discount_percent'],
      ),
      hasDiscount: parseApiNullableBool(json['has_discount']) ?? false,
    );
  }
}
