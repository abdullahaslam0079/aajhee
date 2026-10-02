import 'package:aajhee/src/features/commerce/domain/entities/commerce_product.dart';

/// One page of `/api/products`.
class ProductPage {
  const ProductPage({
    required this.products,
    required this.hasMore,
  });

  final List<CommerceProduct> products;
  final bool hasMore;

  factory ProductPage.fromJson(Map<String, dynamic> json) {
    final raw = json['results'];
    final products = raw is List
        ? raw
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (item) =>
                  CommerceProduct.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
        : const <CommerceProduct>[];
    return ProductPage(
      products: products,
      hasMore: json['next'] != null,
    );
  }
}
