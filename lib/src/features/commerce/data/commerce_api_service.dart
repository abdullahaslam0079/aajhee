import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:aajhee/src/config/app_config.dart';
import 'package:aajhee/src/services/dio_service.dart';
import 'package:aajhee/src/utils/utils.dart';
import 'package:fpdart/fpdart.dart';

class CommerceApiService {
  CommerceApiService(this._dio);

  final DioService _dio;

  FutureEither<Map<String, dynamic>> getHomeFeeds({
    String? addressId,
  }) async {
    final result = await _dio.get(
      '/api/feeds/home',
      queryParameters: {
        if (addressId != null && addressId.isNotEmpty) 'address_id': addressId,
      },
    );
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<Map<String, dynamic>> listProducts({
    int page = 1,
    int pageSize = 20,
    String? query,
    int? categoryId,
  }) async {
    final result = await _dio.get(
      '/api/products',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (categoryId != null) 'category_id': categoryId,
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
      '/api/stores/branch/$branchId/catalog',
      queryParameters: {
        if (addressId != null && addressId.isNotEmpty) 'address_id': addressId,
      },
    );
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<Map<String, dynamic>> getBusinessCatalog(int businessId) async {
    final result = await _dio.get('/api/stores/business/$businessId/catalog');
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<Map<String, dynamic>> getProduct(
    int productId, {
    int? branchId,
  }) async {
    final result = await _dio.get(
      '/api/products/$productId',
      queryParameters: {
        if (branchId != null) 'branch_id': branchId,
      },
    );
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<void> viewProduct(int productId) async {
    final result = await _dio.post('/api/products/$productId/view');
    return result.map((_) {});
  }

  FutureEither<Map<String, dynamic>> getCart() async {
    final result = await _dio.get('/api/cart');
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
      '/api/cart/items',
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
      final result = await _dio.delete('/api/cart/items/$itemId');
      return result.map((_) {});
    }
    final result = await _dio.patch(
      '/api/cart/items/$itemId',
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
      '/api/checkout/preview',
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
    String? customerPhone,
    Map<int, MultipartFile>? paymentProofs,
  }) async {
    final hasProofs = paymentProofs != null && paymentProofs.isNotEmpty;
    if (hasProofs) {
      final formMap = <String, dynamic>{
        'groups': jsonEncode(groups),
        if (customerPhone != null && customerPhone.isNotEmpty)
          'customer_phone': customerPhone,
      };
      for (final entry in paymentProofs.entries) {
        formMap['proof_${entry.key}'] = entry.value;
      }
      final result = await runTask(
        () => AppConfig.dio.post<dynamic>(
          '/api/checkout/place',
          data: FormData.fromMap(formMap),
          queryParameters: {
            if (addressId != null && addressId.isNotEmpty) 'address_id': addressId,
          },
          options: Options(
            contentType: 'multipart/form-data',
            headers: {'Content-Type': 'multipart/form-data'},
          ),
        ),
        requiresNetwork: true,
      );
      return result.fold(left, (r) {
        final data = r.data;
        if (data is List) {
          return right(
            data
                .whereType<Map<dynamic, dynamic>>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList(),
          );
        }
        return left(const ServerFailure('Unexpected checkout response.'));
      });
    }

    final result = await _dio.post(
      '/api/checkout/place',
      data: {
        'groups': groups,
        if (customerPhone != null && customerPhone.isNotEmpty)
          'customer_phone': customerPhone,
      },
      queryParameters: {
        if (addressId != null && addressId.isNotEmpty) 'address_id': addressId,
      },
    );
    return result.fold(left, (r) {
      final data = r.data;
      if (data is List) return right(data.cast<Map<String, dynamic>>());
      return left(const ServerFailure('Unexpected checkout response.'));
    });
  }

  FutureEither<List<Map<String, dynamic>>> getOrders({
    String? statusGroup,
  }) async {
    final result = await _dio.get(
      '/api/orders',
      queryParameters: {
        if (statusGroup != null && statusGroup.isNotEmpty)
          'status_group': statusGroup,
      },
    );
    return result.fold(left, (r) {
      final data = r.data;
      if (data is List) return right(data.cast<Map<String, dynamic>>());
      if (data is Map && data['results'] is List) {
        return right((data['results'] as List).cast<Map<String, dynamic>>());
      }
      return left(const ServerFailure('Unexpected orders response.'));
    });
  }

  FutureEither<Map<String, dynamic>> getOrder(String publicId) async {
    final result = await _dio.get('/api/orders/$publicId');
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<Map<String, dynamic>> cancelOrder(
    String publicId, {
    String reason = '',
  }) async {
    final result = await _dio.post(
      '/api/orders/$publicId/cancel',
      data: {'reason': reason},
    );
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }

  FutureEither<Map<String, dynamic>> reportOrderProblem({
    required String publicId,
    required String message,
  }) async {
    final result = await _dio.post(
      '/api/orders/$publicId/report',
      data: {'message': message.trim()},
    );
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
      () => AppConfig.dio.post<dynamic>(
        '/api/orders/$publicId/payment-proof',
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

  FutureEither<Map<String, dynamic>> createOrderItemReview({
    required String publicId,
    required int itemId,
    required int rating,
    String comment = '',
    List<MultipartFile> images = const [],
  }) async {
    final map = <String, dynamic>{
      'rating': rating,
      'comment': comment,
    };
    if (images.isNotEmpty) {
      map['images'] = images;
    }
    final form = FormData.fromMap(map);
    final result = await runTask(
      () => AppConfig.dio.post<dynamic>(
        '/api/orders/$publicId/items/$itemId/reviews',
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

  FutureEither<Map<String, dynamic>> updateReview({
    required int reviewId,
    int? rating,
    String? comment,
    List<MultipartFile>? images,
    bool replaceImages = false,
  }) async {
    final map = <String, dynamic>{
      'replace_images': replaceImages,
    };
    if (rating != null) map['rating'] = rating;
    if (comment != null) map['comment'] = comment;
    if (images != null && images.isNotEmpty) map['images'] = images;
    final form = FormData.fromMap(map);
    final result = await runTask(
      () => AppConfig.dio.patch<dynamic>(
        '/api/reviews/$reviewId',
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

  FutureEither<Map<String, dynamic>> getProductReviews(
    int productId, {
    int page = 1,
    String sort = 'newest',
    int? branchId,
  }) async {
    final result = await _dio.get(
      '/api/products/$productId/reviews',
      queryParameters: {
        'page': page,
        'sort': sort,
        if (branchId != null) 'branch_id': branchId,
      },
    );
    return result.fold(
      left,
      (r) => right(Map<String, dynamic>.from(r.data as Map)),
    );
  }
}
