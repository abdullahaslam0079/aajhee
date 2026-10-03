import 'package:dio/dio.dart';
import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/commerce/domain/entities/cart_line.dart';
import 'package:aajhee/src/features/commerce/domain/entities/checkout_preview.dart';
import 'package:aajhee/src/features/commerce/domain/entities/customer_order.dart';
import 'package:aajhee/src/features/commerce/domain/entities/home_feeds.dart';
import 'package:aajhee/src/features/commerce/domain/entities/product_page.dart';
import 'package:aajhee/src/features/commerce/domain/entities/upload_file.dart';
import 'package:aajhee/src/features/commerce/domain/repositories/commerce_repository.dart';
import 'package:aajhee/src/utils/typedefs.dart';

class CommerceRepositoryImpl implements CommerceRepository {
  CommerceRepositoryImpl(this._api);

  final CommerceApiService _api;

  @override
  FutureEither<HomeFeeds> getHomeFeeds({String? addressId}) async {
    final result = await _api.getHomeFeeds(addressId: addressId);
    return result.map(HomeFeeds.fromJson);
  }

  @override
  FutureEither<ProductPage> listProducts({
    int page = 1,
    int pageSize = 20,
    String? query,
    int? categoryId,
  }) async {
    final result = await _api.listProducts(
      page: page,
      pageSize: pageSize,
      query: query,
      categoryId: categoryId,
    );
    return result.map(ProductPage.fromJson);
  }

  @override
  FutureEither<Map<String, dynamic>> getBranchCatalog(
    int branchId, {
    String? addressId,
  }) {
    return _api.getBranchCatalog(branchId, addressId: addressId);
  }

  @override
  FutureEither<Map<String, dynamic>> getBusinessCatalog(int businessId) {
    return _api.getBusinessCatalog(businessId);
  }

  @override
  FutureEither<Map<String, dynamic>> getProduct(
    int productId, {
    int? branchId,
  }) {
    return _api.getProduct(productId, branchId: branchId);
  }

  @override
  FutureEither<void> viewProduct(int productId) {
    return _api.viewProduct(productId);
  }

  @override
  FutureEither<CartSnapshot> getCart() async {
    final result = await _api.getCart();
    return result.map(CartSnapshot.fromJson);
  }

  @override
  FutureEither<void> addToCart({
    required int productId,
    int quantity = 1,
    int? branchId,
  }) async {
    final result = await _api.addToCart(
      productId: productId,
      quantity: quantity,
      branchId: branchId,
    );
    return result.map((_) {});
  }

  @override
  FutureEither<void> updateCartItem(int itemId, int quantity) {
    return _api.updateCartItem(itemId, quantity);
  }

  @override
  FutureEither<CheckoutPreview> checkoutPreview({
    required int branchId,
    required List<int> itemIds,
    String? addressId,
  }) async {
    final result = await _api.checkoutPreview(
      branchId: branchId,
      itemIds: itemIds,
      addressId: addressId,
    );
    return result.map(CheckoutPreview.fromJson);
  }

  @override
  FutureEither<List<Map<String, dynamic>>> placeOrders({
    required List<Map<String, dynamic>> groups,
    String? addressId,
    String? customerPhone,
    Map<int, UploadFile>? paymentProofs,
  }) async {
    final proofs = <int, MultipartFile>{};
    for (final entry in paymentProofs?.entries ?? const <MapEntry<int, UploadFile>>[]) {
      proofs[entry.key] = await MultipartFile.fromFile(
        entry.value.path,
        filename: entry.value.filename,
      );
    }
    return _api.placeOrders(
      groups: groups,
      addressId: addressId,
      customerPhone: customerPhone,
      paymentProofs: proofs.isEmpty ? null : proofs,
    );
  }

  @override
  FutureEither<List<OrderSummary>> getOrders({String? statusGroup}) async {
    final result = await _api.getOrders(statusGroup: statusGroup);
    return result.map(
      (items) => items.map(OrderSummary.fromJson).toList(),
    );
  }

  @override
  FutureEither<OrderDetail> getOrder(String publicId) async {
    final result = await _api.getOrder(publicId);
    return result.map(OrderDetail.fromJson);
  }

  @override
  FutureEither<Map<String, dynamic>> cancelOrder(
    String publicId, {
    String reason = '',
  }) {
    return _api.cancelOrder(publicId, reason: reason);
  }

  @override
  FutureEither<Map<String, dynamic>> reportOrderProblem({
    required String publicId,
    required String message,
  }) {
    return _api.reportOrderProblem(publicId: publicId, message: message);
  }

  @override
  FutureEither<Map<String, dynamic>> uploadPaymentProof({
    required String publicId,
    required UploadFile file,
    String note = '',
  }) async {
    return _api.uploadPaymentProof(
      publicId: publicId,
      file: await MultipartFile.fromFile(file.path, filename: file.filename),
      note: note,
    );
  }

  @override
  FutureEither<Map<String, dynamic>> createOrderItemReview({
    required String publicId,
    required int itemId,
    required int rating,
    String comment = '',
    List<UploadFile> images = const [],
  }) async {
    return _api.createOrderItemReview(
      publicId: publicId,
      itemId: itemId,
      rating: rating,
      comment: comment,
      images: await _files(images),
    );
  }

  @override
  FutureEither<Map<String, dynamic>> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
    List<UploadFile>? images,
    bool replaceImages = false,
  }) async {
    return _api.updateReview(
      reviewId: reviewId,
      rating: rating,
      comment: comment,
      images: images == null ? null : await _files(images),
      replaceImages: replaceImages,
    );
  }

  Future<List<MultipartFile>> _files(List<UploadFile> images) {
    return Future.wait(
      images.map(
        (file) => MultipartFile.fromFile(file.path, filename: file.filename),
      ),
    );
  }

  @override
  FutureEither<Map<String, dynamic>> getProductReviews(
    int productId, {
    int page = 1,
    String sort = 'newest',
    int? branchId,
  }) {
    return _api.getProductReviews(
      productId,
      page: page,
      sort: sort,
      branchId: branchId,
    );
  }
}
