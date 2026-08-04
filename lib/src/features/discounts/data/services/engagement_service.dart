import 'package:dio/dio.dart';
import 'package:goluto/src/config/app_config.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/utils/location_query_params.dart';
import 'package:goluto/src/utils/utils.dart';

class OfferEngagementResult {
  const OfferEngagementResult({
    required this.viewCount,
    required this.likeCount,
    required this.isLiked,
  });

  final int viewCount;
  final int likeCount;
  final bool isLiked;
}

class BusinessEngagementResult {
  const BusinessEngagementResult({
    required this.likeCount,
    required this.isLiked,
  });

  final int likeCount;
  final bool isLiked;
}

class EngagementService {
  EngagementService._();
  static final EngagementService instance = EngagementService._();

  Dio get _dio => AppConfig.dio;

  FutureEither<List<OfferModel>> getDiscountsFeed({String? addressId}) async {
    return runTask(() async {
      final response = await _dio.get<List<dynamic>>(
        '/api/offers/discounts',
        queryParameters: LocationQueryParams.fromAddressId(addressId),
      );
      final data = response.data ?? const [];
      return data
          .map((item) => OfferModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }, requiresNetwork: true);
  }

  FutureEither<int> recordOfferView(int offerId) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/offers/$offerId/view',
      );
      final payload = response.data ?? const {};
      return parseApiInt(payload['view_count']);
    }, requiresNetwork: true);
  }

  FutureEither<OfferEngagementResult> toggleOfferLike(int offerId) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/offers/$offerId/like',
      );
      final payload = response.data ?? const {};
      return OfferEngagementResult(
        viewCount: 0,
        likeCount: parseApiInt(payload['like_count']),
        isLiked: payload['is_liked'] as bool? ?? false,
      );
    }, requiresNetwork: true);
  }

  FutureEither<BusinessEngagementResult> toggleBusinessLike(int businessId) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/businesses/$businessId/like',
      );
      final payload = response.data ?? const {};
      return BusinessEngagementResult(
        likeCount: parseApiInt(payload['like_count']),
        isLiked: payload['is_liked'] as bool? ?? false,
      );
    }, requiresNetwork: true);
  }
}
