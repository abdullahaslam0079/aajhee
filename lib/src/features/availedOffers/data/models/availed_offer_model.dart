import 'package:goluto/src/features/home/data/models/category_model.dart';
import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/utils/api_value_parsers.dart';
import 'package:goluto/src/utils/media_url_utils.dart';

class AvailedOfferBranchModel {
  const AvailedOfferBranchModel({
    required this.id,
    required this.name,
    required this.businessId,
    required this.businessName,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String name;
  final int businessId;
  final String businessName;
  final String formattedAddress;
  final double latitude;
  final double longitude;

  factory AvailedOfferBranchModel.fromJson(Map<String, dynamic> json) {
    return AvailedOfferBranchModel(
      id: parseApiInt(json['id']),
      name: parseApiString(json['name']) ?? '',
      businessId: parseApiInt(json['business_id']),
      businessName: parseApiString(json['business_name']) ?? '',
      formattedAddress: parseApiString(
            json['formattedAddress'] ?? json['formatted_address'],
          ) ??
          '',
      latitude: parseApiDouble(json['latitude']),
      longitude: parseApiDouble(json['longitude']),
    );
  }
}

class AvailedOfferSummaryModel {
  const AvailedOfferSummaryModel({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.categoryId,
    required this.categoryName,
    required this.offerType,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discountPercent,
    required this.itemName,
    required this.originalPrice,
    required this.discountedPrice,
  });

  final int id;
  final int businessId;
  final String businessName;
  final int categoryId;
  final String categoryName;
  final OfferType offerType;
  final String title;
  final String description;
  final String? imageUrl;
  final double discountPercent;
  final String itemName;
  final double? originalPrice;
  final double? discountedPrice;

  CategoryModel get category =>
      CategoryModel(id: categoryId, name: categoryName);

  String get subtitle {
    if (description.trim().isNotEmpty) return description.trim();
    if (itemName.trim().isNotEmpty) return itemName.trim();
    if (offerType == OfferType.percentageBill) {
      return 'On the entire bill';
    }
    return '';
  }

  factory AvailedOfferSummaryModel.fromJson(Map<String, dynamic> json) {
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

    return AvailedOfferSummaryModel(
      id: parseApiInt(json['id']),
      businessId: parseApiInt(json['business_id']),
      businessName: parseApiString(json['business_name']) ?? '',
      categoryId: parseApiInt(json['category_id']),
      categoryName: parseApiString(json['category_name']) ?? '',
      offerType: OfferType.fromApi(parseApiString(json['offer_type']) ?? ''),
      title: parseApiString(json['title']) ?? '',
      description: parseApiString(json['description']) ?? '',
      imageUrl: resolveMediaUrl(parseApiString(json['image_url'])) ??
          (imageUrls.isNotEmpty ? imageUrls.first : null),
      discountPercent: parseApiDouble(json['discount_percent']),
      itemName: parseApiString(json['item_name']) ?? '',
      originalPrice: parseApiNullableDouble(json['original_price']),
      discountedPrice: parseApiNullableDouble(json['discounted_price']),
    );
  }
}

class AvailedOfferModel {
  const AvailedOfferModel({
    required this.id,
    required this.redeemedAt,
    required this.offer,
    required this.branch,
  });

  final int id;
  final DateTime redeemedAt;
  final AvailedOfferSummaryModel offer;
  final AvailedOfferBranchModel branch;

  MapBranchModel toMapBranch() {
    return MapBranchModel(
      id: branch.id,
      businessId: branch.businessId,
      businessName: branch.businessName,
      categoryId: offer.categoryId,
      categoryName: offer.categoryName,
      category: offer.category,
      name: branch.name,
      latitude: branch.latitude,
      longitude: branch.longitude,
      formattedAddress: branch.formattedAddress,
      highestDiscountPercent: offer.discountPercent,
    );
  }

  factory AvailedOfferModel.fromJson(Map<String, dynamic> json) {
    final redeemedAtRaw = parseApiString(json['redeemed_at']);
    final redeemedAt = redeemedAtRaw == null
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.parse(redeemedAtRaw).toLocal();

    return AvailedOfferModel(
      id: parseApiInt(json['id']),
      redeemedAt: redeemedAt,
      offer: AvailedOfferSummaryModel.fromJson(
        json['offer'] as Map<String, dynamic>,
      ),
      branch: AvailedOfferBranchModel.fromJson(
        json['branch'] as Map<String, dynamic>,
      ),
    );
  }
}

String formatAvailedOfferDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/${date.year} · $hour:$minute';
}
