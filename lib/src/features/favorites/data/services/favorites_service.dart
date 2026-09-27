import 'package:dio/dio.dart';
import 'package:aajhee/src/config/app_config.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/utils/location_query_params.dart';
import 'package:aajhee/src/utils/utils.dart';

class BusinessEngagementResult {
  const BusinessEngagementResult({
    required this.likeCount,
    required this.isLiked,
  });

  final int likeCount;
  final bool isLiked;
}

class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  Dio get _dio => AppConfig.dio;

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

    if (likedBranchIds.isEmpty) {
      likedBranchIds.addAll(page.results.map((branch) => branch.id));
    }

    return FavoriteBranchesPage(
      page: page,
      likedBranchIds: likedBranchIds,
    );
  }
}
