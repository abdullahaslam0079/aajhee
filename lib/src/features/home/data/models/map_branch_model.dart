import 'package:aajhee/src/features/home/data/models/branch_discount_summary.dart';
import 'package:aajhee/src/features/home/data/models/category_model.dart';
import 'package:aajhee/src/utils/api_value_parsers.dart';
import 'package:aajhee/src/utils/media_url_utils.dart';

class MapBranchModel {
  const MapBranchModel({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.categoryId,
    required this.categoryName,
    required this.category,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.highestDiscountPercent,
    this.businessLogoUrl,
    this.highestDiscountImageUrl,
    this.discountSummary,
    this.distanceKm,
  });

  final int id;
  final int businessId;
  final String businessName;
  final int categoryId;
  final String categoryName;
  final CategoryModel category;
  final String name;
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final double highestDiscountPercent;
  final String? businessLogoUrl;
  final String? highestDiscountImageUrl;
  final BranchDiscountSummary? discountSummary;
  final double? distanceKm;

  String get displayName => businessName.isNotEmpty ? businessName : name;

  String? get logoUrl => businessLogoUrl;

  String? get coverImageUrl =>
      highestDiscountImageUrl ?? discountSummary?.imageUrl;

  MapBranchModel copyWith({
    int? id,
    int? businessId,
    String? businessName,
    int? categoryId,
    String? categoryName,
    CategoryModel? category,
    String? name,
    double? latitude,
    double? longitude,
    String? formattedAddress,
    double? highestDiscountPercent,
    String? businessLogoUrl,
    String? highestDiscountImageUrl,
    BranchDiscountSummary? discountSummary,
    double? distanceKm,
  }) {
    return MapBranchModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      category: category ?? this.category,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      highestDiscountPercent:
          highestDiscountPercent ?? this.highestDiscountPercent,
      businessLogoUrl: businessLogoUrl ?? this.businessLogoUrl,
      highestDiscountImageUrl:
          highestDiscountImageUrl ?? this.highestDiscountImageUrl,
      discountSummary: discountSummary ?? this.discountSummary,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  factory MapBranchModel.fromJson(Map<String, dynamic> json) {
    final discountJson = json['highest_discount_offer'] as Map<String, dynamic>?;
    final discount = discountJson != null
        ? BranchDiscountSummary.fromJson(discountJson)
        : null;

    return MapBranchModel(
      id: parseApiInt(json['id']),
      businessId: parseApiInt(json['business_id']),
      businessName: parseApiString(json['business_name']) ?? '',
      categoryId: parseApiInt(json['category_id']),
      categoryName: parseApiString(json['category_name']) ?? '',
      category: json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : const CategoryModel(id: 0, name: ''),
      name: parseApiString(json['name']) ?? '',
      latitude: parseApiDouble(json['latitude']),
      longitude: parseApiDouble(json['longitude']),
      formattedAddress: parseApiString(json['formattedAddress']) ?? '',
      highestDiscountPercent: parseApiDouble(
        json['highest_discount_percent'],
        fallback: discount?.discountPercent ?? 0,
      ),
      businessLogoUrl: resolveMediaUrl(
        parseApiString(
          json['business_logo_url'] ??
              json['logo_url'] ??
              json['business_logo'] ??
              json['logo'],
        ),
      ),
      highestDiscountImageUrl: resolveMediaUrl(
        parseApiString(json['highest_discount_offer_image_url']),
      ),
      discountSummary: discount,
      distanceKm: parseApiNullableDouble(json['distance_km']),
    );
  }
}
