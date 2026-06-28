import 'package:dio/dio.dart';
import 'package:goluto/src/config/app_config.dart';
import 'package:goluto/src/features/home/data/models/category_model.dart';
import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
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

  FutureEither<List<MapBranchModel>> getMapBranches({String? addressId}) async {
    return runTask(() async {
      final response = await _dio.get<List<dynamic>>(
        '/api/map/branches',
        queryParameters: LocationQueryParams.fromAddressId(addressId),
      );
      final data = response.data ?? const [];
      return data
          .map((item) => MapBranchModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }, requiresNetwork: true);
  }

  FutureEither<MapBranchModel?> findBranchById(
    int branchId, {
    String? addressId,
  }) async {
    return runTask(() async {
      final response = await _dio.get<List<dynamic>>(
        '/api/map/branches',
        queryParameters: LocationQueryParams.fromAddressId(addressId),
      );
      final data = response.data ?? const [];
      for (final item in data) {
        final branch =
            MapBranchModel.fromJson(item as Map<String, dynamic>);
        if (branch.id == branchId) return branch;
      }
      return null;
    }, requiresNetwork: true);
  }

  FutureEither<List<OfferModel>> getOffers({String? addressId}) async {
    return runTask(() async {
      final response = await _dio.get<List<dynamic>>(
        '/api/offers',
        queryParameters: LocationQueryParams.fromAddressId(addressId),
      );
      final data = response.data ?? const [];
      return data
          .map((item) => OfferModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }, requiresNetwork: true);
  }

  FutureEither<List<OfferModel>> getBranchOffers(int branchId) async {
    return runTask(() async {
      final response = await _dio.get<List<dynamic>>(
        '/api/branch/$branchId/offers',
      );
      final data = response.data ?? const [];
      return data
          .map((item) => OfferModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }, requiresNetwork: true);
  }
}
