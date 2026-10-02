import 'dart:async';

import 'package:aajhee/src/features/commerce/domain/entities/cart_line.dart';
import 'package:aajhee/src/features/commerce/domain/entities/checkout_preview.dart';
import 'package:aajhee/src/features/commerce/domain/entities/customer_order.dart';
import 'package:aajhee/src/features/commerce/domain/entities/product_page.dart';
import 'package:aajhee/src/features/commerce/domain/entities/upload_file.dart';
import 'package:aajhee/src/features/commerce/domain/repositories/commerce_repository.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_repository_provider.dart';
import 'package:aajhee/src/utils/failure.dart';
import 'package:aajhee/src/utils/typedefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  test('a slow cart refresh cannot rewind a newer quantity', () async {
    final repo = _SlowCartRepository();
    final container = ProviderContainer(
      overrides: [
        commerceRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    container.read(cartProvider);
    await pumpEventQueue();

    expect(container.read(cartProvider).items.single.quantity, 1);

    final first = container.read(cartProvider.notifier).setQuantity(7, 2);
    await pumpEventQueue();
    expect(repo.updates, [2]);
    expect(repo.heldRead, isNotNull);

    final second = container.read(cartProvider.notifier).setQuantity(7, 3);
    await pumpEventQueue();
    expect(repo.updates, [2]);

    repo.heldRead!.complete();
    final results = await Future.wait([first, second]);

    expect(results, [true, true]);
    expect(repo.updates, [2, 3]);
    expect(container.read(cartProvider).items.single.quantity, 3);
  });
}

class _SlowCartRepository implements CommerceRepository {
  final updates = <int>[];
  int quantity = 1;
  int _reads = 0;
  Completer<void>? heldRead;

  CartLine _line(int quantity) {
    return CartLine.fromJson({
      'id': 7,
      'quantity': quantity,
      'product_id': 3,
      'branch_id': 9,
      'line_total': '20',
      'product': {'id': 3, 'name': 'Atta'},
    });
  }

  @override
  FutureEither<CartSnapshot> getCart() async {
    _reads++;
    final seen = quantity;
    if (_reads == 2) {
      heldRead = Completer<void>();
      await heldRead!.future;
    }
    return right(
      CartSnapshot(items: [_line(seen)], subtotal: '20'),
    );
  }

  @override
  FutureEither<void> updateCartItem(int itemId, int quantity) async {
    updates.add(quantity);
    this.quantity = quantity;
    return right(null);
  }

  FutureEither<T> _unused<T>() async => left(const ServerFailure('unused'));

  @override
  FutureEither<void> addToCart({
    required int productId,
    int quantity = 1,
    int? branchId,
  }) =>
      _unused();

  @override
  FutureEither<Map<String, dynamic>> cancelOrder(
    String publicId, {
    String reason = '',
  }) =>
      _unused();

  @override
  FutureEither<CheckoutPreview> checkoutPreview({
    required int branchId,
    required List<int> itemIds,
    String? addressId,
  }) =>
      _unused();

  @override
  FutureEither<Map<String, dynamic>> createOrderItemReview({
    required String publicId,
    required int itemId,
    required int rating,
    String comment = '',
    List<UploadFile> images = const [],
  }) =>
      _unused();

  @override
  FutureEither<Map<String, dynamic>> getBranchCatalog(
    int branchId, {
    String? addressId,
  }) =>
      _unused();

  @override
  FutureEither<Map<String, dynamic>> getBusinessCatalog(int businessId) =>
      _unused();

  @override
  FutureEither<OrderDetail> getOrder(String publicId) => _unused();

  @override
  FutureEither<List<OrderSummary>> getOrders({String? statusGroup}) =>
      _unused();

  @override
  FutureEither<Map<String, dynamic>> getProduct(int productId) => _unused();

  @override
  FutureEither<Map<String, dynamic>> getProductReviews(
    int productId, {
    int page = 1,
    String sort = 'newest',
  }) =>
      _unused();

  @override
  FutureEither<ProductPage> listProducts({
    int page = 1,
    int pageSize = 20,
    String? query,
    int? categoryId,
  }) =>
      _unused();

  @override
  FutureEither<List<Map<String, dynamic>>> placeOrders({
    required List<Map<String, dynamic>> groups,
    String? addressId,
    String? customerPhone,
    Map<int, UploadFile>? paymentProofs,
  }) =>
      _unused();

  @override
  FutureEither<Map<String, dynamic>> reportOrderProblem({
    required String publicId,
    required String message,
  }) =>
      _unused();

  @override
  FutureEither<Map<String, dynamic>> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
    List<UploadFile>? images,
    bool replaceImages = false,
  }) =>
      _unused();

  @override
  FutureEither<Map<String, dynamic>> uploadPaymentProof({
    required String publicId,
    required UploadFile file,
    String note = '',
  }) =>
      _unused();

  @override
  FutureEither<void> viewProduct(int productId) => _unused();
}
