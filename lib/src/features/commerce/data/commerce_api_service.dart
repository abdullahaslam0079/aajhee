import 'package:dio/dio.dart';
import 'package:aajhee/src/config/app_config.dart';
import 'package:aajhee/src/services/dio_service.dart';
import 'package:aajhee/src/utils/failure.dart';
import 'package:aajhee/src/utils/typedefs.dart';
import 'package:aajhee/src/utils/utils.dart';
import 'package:fpdart/fpdart.dart';

class CommerceApiService {
  CommerceApiService(this._dio);

  final DioService _dio;

  FutureEither<Map<String, dynamic>> getHomeFeeds({
    String? addressId,
  }) async {
    final result = await _dio.get(
      '/feeds/home',
      queryParameters: {
        if (addressId != null && addressId.isNotEmpty) 'address_id': addressId,
      },
    );
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<Map<String, dynamic>> getBranchCatalog(
    int branchId, {
    String? addressId,
  }) async {
    final result = await _dio.get(
      '/stores/branch/$branchId/catalog',
      queryParameters: {
        if (addressId != null && addressId.isNotEmpty) 'address_id': addressId,
      },
    );
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<Map<String, dynamic>> getProduct(int productId) async {
    final result = await _dio.get('/products/$productId');
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<void> viewProduct(int productId) async {
    final result = await _dio.post('/products/$productId/view');
    return result.map((_) {});
  }

  FutureEither<Map<String, dynamic>> getCart() async {
    final result = await _dio.get('/cart');
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<Map<String, dynamic>> addToCart({
    required int productId,
    int quantity = 1,
    int? branchId,
  }) async {
    final result = await _dio.post(
      '/cart/items',
      data: {
        'product_id': productId,
        'quantity': quantity,
        if (branchId != null) 'branch_id': branchId,
      },
    );
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<void> updateCartItem(int itemId, int quantity) async {
    if (quantity < 1) {
      final result = await _dio.delete('/cart/items/$itemId');
      return result.map((_) {});
    }
    final result = await _dio.patch(
      '/cart/items/$itemId',
      data: {'quantity': quantity},
    );
    return result.map((_) {});
  }

  FutureEither<Map<String, dynamic>> checkoutPreview({
    required int branchId,
    required List<int> itemIds,
    String? addressId,
  }) async {
    final result = await _dio.post(
      '/checkout/preview',
      data: {'branch_id': branchId, 'item_ids': itemIds},
      queryParameters: {
        if (addressId != null && addressId.isNotEmpty) 'address_id': addressId,
      },
    );
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<List<Map<String, dynamic>>> placeOrders({
    required List<Map<String, dynamic>> groups,
    String? addressId,
  }) async {
    final result = await _dio.post(
      '/checkout/place',
      data: {'groups': groups},
      queryParameters: {
        if (addressId != null && addressId.isNotEmpty) 'address_id': addressId,
      },
    );
    return result.fold(left, (r) {
      final data = r.data;
      if (data is List) return right(data.cast<Map<String, dynamic>>());
      return left(ServerFailure('Unexpected checkout response.'));
    });
  }

  FutureEither<List<Map<String, dynamic>>> getOrders() async {
    final result = await _dio.get('/orders');
    return result.fold(left, (r) {
      final data = r.data;
      if (data is List) return right(data.cast<Map<String, dynamic>>());
      if (data is Map && data['results'] is List) {
        return right((data['results'] as List).cast<Map<String, dynamic>>());
      }
      return left(ServerFailure('Unexpected orders response.'));
    });
  }

  FutureEither<Map<String, dynamic>> getOrder(String publicId) async {
    final result = await _dio.get('/orders/$publicId');
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<Map<String, dynamic>> cancelOrder(String publicId) async {
    final result = await _dio.post('/orders/$publicId/cancel');
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<Map<String, dynamic>> uploadPaymentProof({
    required String publicId,
    required MultipartFile file,
    String note = '',
  }) async {
    final form = FormData.fromMap({
      'file': file,
      'note': note,
    });
    final result = await runTask(
      () => AppConfig.dio.post(
        '/orders/$publicId/payment-proof',
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      ),
      requiresNetwork: true,
    );
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }
}
