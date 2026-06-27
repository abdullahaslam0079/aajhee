import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/utils/api_value_parsers.dart';
import 'package:goluto/src/utils/media_url_utils.dart';

class BranchTopOfferModel {
  const BranchTopOfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.offerType,
    required this.discountPercent,
    required this.itemName,
    required this.originalPrice,
    required this.discountedPrice,
    required this.imageUrl,
    required this.isActive,
  });

  final int id;
  final String title;
  final String description;
  final OfferType offerType;
  final double discountPercent;
  final String itemName;
  final double? originalPrice;
  final double? discountedPrice;
  final String? imageUrl;
  final bool isActive;

  factory BranchTopOfferModel.fromJson(Map<String, dynamic> json) {
    return BranchTopOfferModel(
      id: parseApiInt(json['id']),
      title: parseApiString(json['title']) ?? '',
      description: parseApiString(json['description']) ?? '',
      offerType: OfferType.fromApi(parseApiString(json['offer_type']) ?? ''),
      discountPercent: parseApiDouble(json['discount_percent']),
      itemName: parseApiString(json['item_name']) ?? '',
      originalPrice: parseApiNullableDouble(json['original_price']),
      discountedPrice: parseApiNullableDouble(json['discounted_price']),
      imageUrl: resolveMediaUrl(parseApiString(json['image_url'])),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
