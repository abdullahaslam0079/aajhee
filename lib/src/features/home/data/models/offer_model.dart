import 'package:goluto/src/features/home/data/models/category_model.dart';
import 'package:goluto/src/utils/api_value_parsers.dart';
import 'package:goluto/src/utils/media_url_utils.dart';

enum OfferType {
  percentageBill('percentage_bill'),
  item('item');

  const OfferType(this.apiValue);

  final String apiValue;

  static OfferType fromApi(String value) {
    return OfferType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => OfferType.percentageBill,
    );
  }
}

class OfferModel {
  const OfferModel({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.categoryId,
    required this.categoryName,
    required this.category,
    required this.branchIds,
    required this.offerType,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discountPercent,
    required this.itemName,
    required this.originalPrice,
    required this.discountedPrice,
    required this.usageLimitType,
    required this.usageLimitCount,
    required this.isEnabled,
    required this.isTimeLimited,
    required this.startsAt,
    required this.endsAt,
    required this.qrCode,
    required this.isActive,
  });

  final int id;
  final int businessId;
  final String businessName;
  final int categoryId;
  final String categoryName;
  final CategoryModel category;
  final List<int> branchIds;
  final OfferType offerType;
  final String title;
  final String description;
  final String? imageUrl;
  final double discountPercent;
  final String itemName;
  final double? originalPrice;
  final double? discountedPrice;
  final String usageLimitType;
  final int usageLimitCount;
  final bool isEnabled;
  final bool isTimeLimited;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String qrCode;
  final bool isActive;

  String get subtitle {
    if (description.trim().isNotEmpty) return description.trim();
    if (itemName.trim().isNotEmpty) return itemName.trim();
    if (offerType == OfferType.percentageBill) {
      return 'On the entire bill';
    }
    return '';
  }

  String get detailText {
    if (originalPrice != null && discountedPrice != null) {
      return 'Instead of ${originalPrice!.toStringAsFixed(0)}';
    }
    if (isTimeLimited && endsAt != null) {
      return 'Valid until ${_formatDate(endsAt!)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: parseApiInt(json['id']),
      businessId: parseApiInt(json['business_id']),
      businessName: parseApiString(json['business_name']) ?? '',
      categoryId: parseApiInt(json['category_id']),
      categoryName: parseApiString(json['category_name']) ?? '',
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      branchIds: (json['branch_ids'] as List<dynamic>? ?? [])
          .map((id) => parseApiInt(id))
          .toList(),
      offerType: OfferType.fromApi(parseApiString(json['offer_type']) ?? ''),
      title: parseApiString(json['title']) ?? '',
      description: parseApiString(json['description']) ?? '',
      imageUrl: resolveMediaUrl(parseApiString(json['image_url'])),
      discountPercent: parseApiDouble(json['discount_percent']),
      itemName: parseApiString(json['item_name']) ?? '',
      originalPrice: parseApiNullableDouble(json['original_price']),
      discountedPrice: parseApiNullableDouble(json['discounted_price']),
      usageLimitType: parseApiString(json['usage_limit_type']) ?? '',
      usageLimitCount: parseApiInt(json['usage_limit_count']),
      isEnabled: json['is_enabled'] as bool? ?? true,
      isTimeLimited: json['is_time_limited'] as bool? ?? false,
      startsAt: _parseNullableDate(json['starts_at']),
      endsAt: _parseNullableDate(json['ends_at']),
      qrCode: parseApiString(json['qr_code']) ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) return null;
    return DateTime.tryParse(parseApiString(value) ?? '');
  }
}
