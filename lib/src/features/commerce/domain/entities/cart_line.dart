import 'package:aajhee/src/features/commerce/domain/entities/commerce_product.dart';
import 'package:aajhee/src/utils/api_value_parsers.dart';

/// One row in the customer's cart.
class CartLine {
  const CartLine({
    required this.id,
    required this.quantity,
    required this.product,
    this.productId,
    this.branchId,
    this.unitPrice,
    this.lineTotal,
  });

  final int id;
  final int quantity;
  final int? productId;
  final int? branchId;
  final dynamic unitPrice;
  final dynamic lineTotal;
  final CommerceProduct product;

  dynamic get displayUnitPrice =>
      unitPrice ?? product.effectivePrice ?? product.basePrice;

  dynamic get displayLineTotal => lineTotal ?? displayUnitPrice;

  factory CartLine.fromJson(Map<String, dynamic> json) {
    final rawProduct = json['product'];
    final product = rawProduct is Map
        ? CommerceProduct.fromJson(Map<String, dynamic>.from(rawProduct))
        : const CommerceProduct(<String, dynamic>{});
    return CartLine(
      id: parseApiInt(json['id']),
      quantity: parseApiInt(json['quantity'], fallback: 1),
      productId: parseApiNullableInt(json['product_id']) ?? product.id,
      branchId: parseApiNullableInt(json['branch_id']),
      unitPrice: json['unit_price'],
      lineTotal: json['line_total'],
      product: product,
    );
  }

  CartLine copyWith({int? quantity}) {
    return CartLine(
      id: id,
      quantity: quantity ?? this.quantity,
      product: product,
      productId: productId,
      branchId: branchId,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
    );
  }

  /// Branch used at checkout. Prefers the cart row, then the product's branches.
  int? get checkoutBranchId {
    if (branchId != null) return branchId;
    if (product.branchIds.isEmpty) return null;
    return product.branchIds.first;
  }

  bool matchesProduct(int requestedProductId, {int? requestedBranchId}) {
    final pid = product.id ?? productId;
    final matchesProduct = pid == requestedProductId;
    if (!matchesProduct) return false;
    if (requestedBranchId == null) return true;
    return branchId == requestedBranchId;
  }
}

class CartSnapshot {
  const CartSnapshot({
    this.items = const [],
    this.subtotal,
  });

  final List<CartLine> items;
  final String? subtotal;

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  factory CartSnapshot.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = raw is List
        ? raw
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (item) => CartLine.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
        : const <CartLine>[];
    return CartSnapshot(
      items: items,
      subtotal: json['subtotal']?.toString(),
    );
  }

  CartLine? lineForProduct(int productId, {int? branchId}) {
    for (final item in items) {
      if (item.matchesProduct(productId, requestedBranchId: branchId)) {
        return item;
      }
    }
    if (branchId == null) return null;
    for (final item in items) {
      if (item.matchesProduct(productId)) return item;
    }
    return null;
  }

  CartSnapshot copyWithItems(List<CartLine> items) {
    return CartSnapshot(items: items, subtotal: subtotal);
  }
}
