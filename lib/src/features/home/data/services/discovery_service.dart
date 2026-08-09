import 'package:dio/dio.dart';
import 'package:goluto/src/config/app_config.dart';
import 'package:goluto/src/features/home/data/models/category_model.dart';
import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/searchOffers/data/models/offer_search_page.dart';
import 'package:goluto/src/utils/location_query_params.dart';
import 'package:goluto/src/utils/utils.dart';

class DiscoveryService {
  DiscoveryService._();
  static final DiscoveryService instance = DiscoveryService._();

  Dio get _dio => AppConfig.dio;

  FutureEither<List<CategoryModel>> getCategories() async {
    return runTask(() async {
      final response = await _dio.get<List<dynamic>>('/api/categories');
      final data = response.data ?? const [];
      return data
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }, requiresNetwork: true);
  }

  FutureEither<PaginatedPage<MapBranchModel>> getMapBranches({
    String? addressId,
    int? categoryId,
    int? branchId,
    int? businessId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return runTask(() async {
      final params = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (categoryId != null) 'category_id': categoryId,
        if (branchId != null) 'branch_id': branchId,
        if (businessId != null) 'business_id': businessId,
        ...?LocationQueryParams.fromAddressId(addressId),
      };

      final response = await _dio.get<Map<String, dynamic>>(
        '/api/map/branches',
        queryParameters: params,
      );
      final data = response.data;
      if (data == null) {
        return PaginatedPage.empty<MapBranchModel>(pageSize: pageSize);
      }
      return PaginatedPage.fromJson(data, MapBranchModel.fromJson);
    }, requiresNetwork: true);
  }

  FutureEither<MapBranchModel?> findBranchById(
    int branchId, {
    String? addressId,
  }) async {
    final result = await getMapBranches(
      addressId: addressId,
      branchId: branchId,
      page: 1,
      pageSize: 1,
    );
    return result.map((page) => page.results.isEmpty ? null : page.results.first);
  }

  FutureEither<MapBranchModel?> findBranchByBusinessId(
    int businessId, {
    String? addressId,
  }) async {
    final result = await getMapBranches(
      addressId: addressId,
      businessId: businessId,
      page: 1,
      pageSize: 1,
    );
    return result.map((page) => page.results.isEmpty ? null : page.results.first);
  }

  FutureEither<PaginatedPage<OfferModel>> getOffers({
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
        '/api/offers',
        queryParameters: params,
      );
      final data = response.data;
      if (data == null) {
        return PaginatedPage.empty<OfferModel>(pageSize: pageSize);
      }
      return PaginatedPage.fromJson(data, OfferModel.fromJson);
    }, requiresNetwork: true);
  }

  FutureEither<OfferSearchPage> searchOffers({
    required String query,
    String? addressId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return runTask(() async {
      final params = <String, dynamic>{
        'q': query.trim(),
        'page': page,
        'page_size': pageSize,
        ...?LocationQueryParams.fromAddressId(addressId),
      };

      final response = await _dio.get<Map<String, dynamic>>(
        '/api/offers/search',
        queryParameters: params,
      );
      final data = response.data;
      if (data == null) return OfferSearchPage.empty;
      return OfferSearchPage.fromJson(data);
    }, requiresNetwork: true);
  }

  FutureEither<PaginatedPage<OfferModel>> getBranchOffers(
    int branchId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return runTask(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/branch/$branchId/offers',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      final data = response.data;
      if (data == null) {
        return PaginatedPage.empty<OfferModel>(pageSize: pageSize);
      }
      return PaginatedPage.fromJson(data, OfferModel.fromJson);
    }, requiresNetwork: true);
  }
}
