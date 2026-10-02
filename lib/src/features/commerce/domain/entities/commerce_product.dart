import 'package:aajhee/src/utils/api_value_parsers.dart';

/// A catalog product as the app reads it from list, search, and cart payloads.
class CommerceProduct {
  const CommerceProduct(this.json);

  final Map<String, dynamic> json;

  factory CommerceProduct.fromJson(Map<String, dynamic> json) {
    return CommerceProduct(Map<String, dynamic>.from(json));
  }

  int? get id => parseApiNullableInt(json['id']);

  int? get businessId => parseApiNullableInt(json['business_id']);

  int? get branchId => parseApiNullableInt(json['branch_id']);

  List<int> get branchIds {
    final raw = json['branch_ids'];
    if (raw is! List) return const [];
    return raw.map(parseApiNullableInt).whereType<int>().toList();
  }

  String get name {
    final value = json['name']?.toString().trim() ?? '';
    return value;
  }

  String get displayName => name.isEmpty ? 'Product' : name;

  String? get imageUrl {
    final value = json['image_url']?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? get businessName {
    final value = json['business_name']?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  bool get hasDiscount => json['has_discount'] == true;

  double? get ratingAvg => parseApiNullableDouble(json['rating_avg']);

  int? get ratingCount => parseApiNullableInt(json['rating_count']);

  dynamic get effectivePrice => json['effective_price'];

  dynamic get basePrice => json['base_price'];

  dynamic get effectiveDiscountPercent => json['effective_discount_percent'];

  /// Price used for "low to high" sorting. Missing prices sort last.
  double get sortPrice =>
      parseApiNullableDouble(json['effective_price'] ?? json['base_price']) ??
      double.infinity;

  String? discountLabel({bool short = false}) {
    if (!hasDiscount) return null;
    final parsed = parseApiNullableDouble(effectiveDiscountPercent);
    if (parsed == null || parsed <= 0) return null;
    final value = parsed == parsed.roundToDouble()
        ? '${parsed.toInt()}%'
        : '${parsed.toStringAsFixed(0)}%';
    return short ? '-$value' : '$value off';
  }

  Map<String, dynamic> toJson() => json;
}
