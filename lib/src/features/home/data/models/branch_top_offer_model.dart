import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/utils/api_value_parsers.dart';
import 'package:goluto/src/utils/media_url_utils.dart';

class BranchTopOfferModel {
  const BranchTopOfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.offerType,
    required this.redemptionMode,
    this.isOnline = false,
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
  final OfferRedemptionMode redemptionMode;
  final bool isOnline;
  final double discountPercent;
  final String itemName;
  final double? originalPrice;
  final double? discountedPrice;
  final String? imageUrl;
  final bool isActive;

  factory BranchTopOfferModel.fromJson(Map<String, dynamic> json) {
    final imageUrls = <String>[];
    final rawUrls = json['image_urls'];
    if (rawUrls is List) {
      for (final item in rawUrls) {
        final resolved = resolveMediaUrl(parseApiString(item));
        if (resolved != null && resolved.isNotEmpty) {
          imageUrls.add(resolved);
        }
      }
    }

    return BranchTopOfferModel(
      id: parseApiInt(json['id']),
      title: parseApiString(json['title']) ?? '',
      description: parseApiString(json['description']) ?? '',
      offerType: OfferType.fromApi(parseApiString(json['offer_type']) ?? ''),
      redemptionMode: OfferRedemptionMode.fromApi(
        parseApiString(json['redemption_mode']),
      ),
      isOnline: json['is_online'] as bool? ?? false,
      discountPercent: parseApiDouble(json['discount_percent']),
      itemName: parseApiString(json['item_name']) ?? '',
      originalPrice: parseApiNullableDouble(json['original_price']),
      discountedPrice: parseApiNullableDouble(json['discounted_price']),
      imageUrl: resolveMediaUrl(parseApiString(json['image_url'])) ??
          (imageUrls.isNotEmpty ? imageUrls.first : null),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
