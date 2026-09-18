import 'package:dio/dio.dart';
import 'package:aajhee/src/config/app_config.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/home/data/models/offer_model.dart';
import 'package:aajhee/src/utils/location_query_params.dart';
import 'package:aajhee/src/utils/utils.dart';

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

  FutureEither<PaginatedPage<OfferModel>> getTopPicksFeed({
    String? addressId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return runTask(() async {
      final params = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        ...?LocationQueryParams.fromAddressId(addressId),
      };
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/offers/discounts',
        queryParameters: params,
      );
      final data = response.data;
      if (data == null) {
        return PaginatedPage.empty<OfferModel>(pageSize: pageSize);
      }
      return PaginatedPage.fromJson(data, OfferModel.fromJson);
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

  FutureEither<BusinessEngagementResult> setBusinessLike(
    int businessId, {
    required bool liked,
  }) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/businesses/$businessId/like',
        data: {'liked': liked},
      );
      final payload = response.data ?? const {};
      return BusinessEngagementResult(
        likeCount: parseApiInt(payload['like_count']),
        isLiked: payload['is_liked'] as bool? ?? liked,
      );
    }, requiresNetwork: true);
  }

  FutureEither<BusinessEngagementResult> setBranchLike(
    int branchId, {
    required bool liked,
  }) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/branches/$branchId/like',
        data: {'liked': liked},
      );
      final payload = response.data ?? const {};
      return BusinessEngagementResult(
        likeCount: parseApiInt(payload['like_count']),
        isLiked: payload['is_liked'] as bool? ?? liked,
      );
    }, requiresNetwork: true);
  }

  FutureEither<FavoriteBranchesPage> getFavoriteBranches({
    String? addressId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return runTask(() async {
      final params = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        ...?LocationQueryParams.fromAddressId(addressId),
      };
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/user/favorites',
        queryParameters: params,
      );
      final payload = response.data ?? const {};
      return FavoriteBranchesPage.fromJson(payload);
    }, requiresNetwork: true);
  }
}

class FavoriteBranchesPage {
  const FavoriteBranchesPage({
    required this.page,
    required this.likedBranchIds,
  });

  final PaginatedPage<MapBranchModel> page;
  final Set<int> likedBranchIds;

  bool get hasMore => page.hasMore;

  factory FavoriteBranchesPage.fromJson(Map<String, dynamic> json) {
    final page = PaginatedPage.fromJson(json, MapBranchModel.fromJson);
    final rawBranchIds =
        json['liked_branch_ids'] as List<dynamic>? ?? const [];
    final likedBranchIds = {
      for (final id in rawBranchIds) parseApiInt(id),
    }..remove(0);

    // Fallback for older API responses that only returned business ids +
    // one representative branch per business.
    if (likedBranchIds.isEmpty) {
      likedBranchIds.addAll(page.results.map((branch) => branch.id));
    }

    return FavoriteBranchesPage(
      page: page,
      likedBranchIds: likedBranchIds,
    );
  }
}
