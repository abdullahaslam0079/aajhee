import 'package:aajhee/src/features/home/data/models/branch_discount_summary.dart';
import 'package:aajhee/src/features/home/data/models/branch_top_product_model.dart';
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
    this.ratingAvg,
    this.ratingCount,
    this.isVerified,
    this.supportsSameDay,
    this.supportsNationwide,
    this.deliveryFee,
    this.isOpen,
    this.openingHours,
    this.productsCount = 0,
    this.topProducts = const [],
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

  /// Optional marketplace fields — present when the API sends them.
  final double? ratingAvg;
  final int? ratingCount;
  final bool? isVerified;
  final bool? supportsSameDay;
  final bool? supportsNationwide;
  final double? deliveryFee;
  final bool? isOpen;
  final String? openingHours;

  /// Total active catalog products for this branch (from map list API).
  final int productsCount;

  /// Up to 8 preview products embedded on the branch list payload.
  final List<BranchTopProductModel> topProducts;

  String get displayName => businessName.isNotEmpty ? businessName : name;

  String? get logoUrl => businessLogoUrl;

  String? get coverImageUrl =>
      highestDiscountImageUrl ?? discountSummary?.imageUrl;

  /// Short pin label: shop name preferred, else category. Never a discount %.
  String get mapPinLabel {
    final shop = displayName.trim();
    if (shop.isNotEmpty) {
      return shop.length > 18 ? '${shop.substring(0, 16)}…' : shop;
    }
    final cat = categoryName.trim();
    if (cat.isNotEmpty) {
      return cat.length > 18 ? '${cat.substring(0, 16)}…' : cat;
    }
    return 'Shop';
  }

  /// True when the API marks same-day, or when unset and this is a local
  /// (non-nationwide) shop — used with city checks at the call site.
  bool get treatsAsSameDay {
    if (supportsSameDay == true) return true;
    if (supportsSameDay == false) return false;
    if (supportsNationwide == true) return false;
    return true; // unset → treat as local same-day candidate
  }

  String? get deliveryBadgeLabel {
    if (supportsSameDay == true) return 'Same-day';
    if (supportsNationwide == true) return 'Nationwide';
    if (supportsSameDay == null && supportsNationwide == null) {
      return 'Same-day';
    }
    return null;
  }

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
    double? ratingAvg,
    int? ratingCount,
    bool? isVerified,
    bool? supportsSameDay,
    bool? supportsNationwide,
    double? deliveryFee,
    bool? isOpen,
    String? openingHours,
    int? productsCount,
    List<BranchTopProductModel>? topProducts,
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
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      isVerified: isVerified ?? this.isVerified,
      supportsSameDay: supportsSameDay ?? this.supportsSameDay,
      supportsNationwide: supportsNationwide ?? this.supportsNationwide,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      isOpen: isOpen ?? this.isOpen,
      openingHours: openingHours ?? this.openingHours,
      productsCount: productsCount ?? this.productsCount,
      topProducts: topProducts ?? this.topProducts,
    );
  }

  factory MapBranchModel.fromJson(Map<String, dynamic> json) {
    final discountJson = json['highest_discount_offer'] as Map<String, dynamic>?;
    final discount = discountJson != null
        ? BranchDiscountSummary.fromJson(discountJson)
        : null;

    final fulfillment = json['fulfillment_types'] ?? json['fulfillment_modes'];
    bool? sameDay;
    bool? nationwide;
    if (fulfillment is List) {
      final modes = fulfillment.map((e) => e.toString()).toSet();
      sameDay = modes.contains('local_same_day');
      nationwide = modes.contains('nationwide');
    } else {
      sameDay = parseApiNullableBool(
        json['supports_same_day'] ??
            json['same_day_enabled'] ??
            json['same_day_delivery'],
      );
      nationwide = parseApiNullableBool(
        json['supports_nationwide'] ?? json['nationwide_delivery'],
      );
    }

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
      formattedAddress: parseApiString(json['formattedAddress']) ??
          parseApiString(json['formatted_address']) ??
          '',
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
      ratingAvg: parseApiNullableDouble(
        json['rating_avg'] ?? json['business_rating_avg'],
      ),
      ratingCount: parseApiNullableInt(
        json['rating_count'] ?? json['business_rating_count'],
      ),
      isVerified: parseApiNullableBool(
        json['is_verified'] ?? json['verified'],
      ),
      supportsSameDay: sameDay,
      supportsNationwide: nationwide,
      deliveryFee: parseApiNullableDouble(
        json['delivery_fee'] ?? json['same_day_delivery_fee'],
      ),
      isOpen: parseApiNullableBool(json['is_open'] ?? json['open_now']),
      openingHours: parseApiString(
        json['opening_hours'] ?? json['hours'] ?? json['business_hours'],
      ),
      productsCount: parseApiInt(
        json['products_count'] ?? json['product_count'],
      ),
      topProducts: _parseTopProducts(json['top_products']),
    );
  }

  static List<BranchTopProductModel> _parseTopProducts(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (item) => BranchTopProductModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }
}
