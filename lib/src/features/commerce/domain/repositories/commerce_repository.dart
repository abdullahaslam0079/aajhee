import 'package:aajhee/src/features/commerce/domain/entities/cart_line.dart';
import 'package:aajhee/src/features/commerce/domain/entities/checkout_preview.dart';
import 'package:aajhee/src/features/commerce/domain/entities/customer_order.dart';
import 'package:aajhee/src/features/commerce/domain/entities/home_feeds.dart';
import 'package:aajhee/src/features/commerce/domain/entities/product_page.dart';
import 'package:aajhee/src/features/commerce/domain/entities/upload_file.dart';
import 'package:aajhee/src/utils/typedefs.dart';

/// Commerce data boundary. Presentation calls this, never Dio.
abstract class CommerceRepository {
  FutureEither<HomeFeeds> getHomeFeeds({String? addressId});

  FutureEither<ProductPage> listProducts({
    int page = 1,
    int pageSize = 20,
    String? query,
    int? categoryId,
  });

  FutureEither<Map<String, dynamic>> getBranchCatalog(
    int branchId, {
    String? addressId,
  });

  FutureEither<Map<String, dynamic>> getBusinessCatalog(int businessId);

  FutureEither<Map<String, dynamic>> getProduct(
    int productId, {
    int? branchId,
  });

  FutureEither<void> viewProduct(int productId);

  FutureEither<CartSnapshot> getCart();

  FutureEither<void> addToCart({
    required int productId,
    int quantity = 1,
    int? branchId,
  });

  FutureEither<void> updateCartItem(int itemId, int quantity);

  FutureEither<CheckoutPreview> checkoutPreview({
    required int branchId,
    required List<int> itemIds,
    String? addressId,
  });

  FutureEither<List<Map<String, dynamic>>> placeOrders({
    required List<Map<String, dynamic>> groups,
    String? addressId,
    String? customerPhone,
    Map<int, UploadFile>? paymentProofs,
  });

  FutureEither<List<OrderSummary>> getOrders({String? statusGroup});

  FutureEither<OrderDetail> getOrder(String publicId);

  FutureEither<Map<String, dynamic>> cancelOrder(
    String publicId, {
    String reason = '',
  });

  FutureEither<Map<String, dynamic>> reportOrderProblem({
    required String publicId,
    required String message,
  });

  FutureEither<Map<String, dynamic>> uploadPaymentProof({
    required String publicId,
    required UploadFile file,
    String note = '',
  });

  FutureEither<Map<String, dynamic>> createOrderItemReview({
    required String publicId,
    required int itemId,
    required int rating,
    String comment = '',
    List<UploadFile> images = const [],
  });

  FutureEither<Map<String, dynamic>> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
    List<UploadFile>? images,
    bool replaceImages = false,
  });

  FutureEither<Map<String, dynamic>> getProductReviews(
    int productId, {
    int page = 1,
    String sort = 'newest',
    int? branchId,
  });
}
