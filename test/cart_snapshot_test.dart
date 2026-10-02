import 'package:aajhee/src/features/commerce/domain/entities/cart_line.dart';
import 'package:aajhee/src/features/commerce/domain/entities/commerce_product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CartLine line({
    required int id,
    required int quantity,
    required int productId,
    int? branchId,
    List<int> branchIds = const [],
  }) {
    return CartLine.fromJson({
      'id': id,
      'quantity': quantity,
      'product_id': productId,
      'branch_id': branchId,
      'line_total': '20',
      'product': {
        'id': productId,
        'name': 'Atta',
        'branch_ids': branchIds,
      },
    });
  }

  test('parses cart quantity and matches a product', () {
    final snapshot = CartSnapshot.fromJson({
      'subtotal': '40',
      'items': [
        {
          'id': 7,
          'quantity': 2,
          'product_id': 3,
          'branch_id': 9,
          'product': {'id': 3, 'name': 'Atta'},
        },
        {
          'id': 8,
          'quantity': 1,
          'product_id': 4,
          'branch_id': 9,
          'product': {'id': 4, 'name': 'Rice'},
        },
      ],
    });

    expect(snapshot.subtotal, '40');
    expect(snapshot.totalQuantity, 3);
    expect(snapshot.lineForProduct(3, branchId: 9)?.id, 7);
    expect(snapshot.lineForProduct(4)?.quantity, 1);
    expect(snapshot.lineForProduct(99), isNull);
  });

  test('checkout branch falls back to the product branch list', () {
    final item = line(id: 1, quantity: 1, productId: 5, branchIds: [12, 13]);
    expect(item.branchId, isNull);
    expect(item.checkoutBranchId, 12);
    expect(item.product, isA<CommerceProduct>());
  });

  test('quantity updates do not change the line id', () {
    final item = line(id: 4, quantity: 1, productId: 8, branchId: 2);
    expect(item.copyWith(quantity: 3).id, 4);
    expect(item.copyWith(quantity: 3).quantity, 3);
  });
}
