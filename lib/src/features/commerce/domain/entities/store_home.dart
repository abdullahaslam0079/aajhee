import 'package:aajhee/src/features/commerce/domain/entities/commerce_product.dart';
import 'package:aajhee/src/utils/api_value_parsers.dart';

/// Shelf previews from `GET /api/stores/.../home`.
class StoreHome {
  const StoreHome({
    required this.deals,
    required this.categories,
  });

  final StoreDealsShelf deals;
  final List<StoreCategoryShelf> categories;

  factory StoreHome.fromJson(Map<String, dynamic> json) {
    return StoreHome(
      deals: StoreDealsShelf.fromJson(
        Map<String, dynamic>.from(json['deals'] as Map? ?? const {}),
      ),
      categories: (json['categories'] as List? ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (item) =>
                StoreCategoryShelf.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  bool get isEmpty => deals.count == 0 && categories.isEmpty;
}

class StoreDealsShelf {
  const StoreDealsShelf({
    required this.count,
    required this.preview,
  });

  final int count;
  final List<CommerceProduct> preview;

  factory StoreDealsShelf.fromJson(Map<String, dynamic> json) {
    return StoreDealsShelf(
      count: parseApiInt(json['count']),
      preview: _parseProducts(json['preview']),
    );
  }
}

class StoreCategoryShelf {
  const StoreCategoryShelf({
    required this.categoryId,
    required this.categoryName,
    required this.productCount,
    required this.preview,
  });

  final int categoryId;
  final String categoryName;
  final int productCount;
  final List<CommerceProduct> preview;

  factory StoreCategoryShelf.fromJson(Map<String, dynamic> json) {
    return StoreCategoryShelf(
      categoryId: parseApiInt(json['category_id']),
      categoryName: parseApiString(json['category_name']) ?? 'Category',
      productCount: parseApiInt(json['product_count']),
      preview: _parseProducts(json['preview']),
    );
  }
}

List<CommerceProduct> _parseProducts(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map<dynamic, dynamic>>()
      .map((item) => CommerceProduct.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}
