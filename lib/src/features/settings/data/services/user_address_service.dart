import 'package:dio/dio.dart';
import 'package:aajhee/src/config/app_config.dart';
import 'package:aajhee/src/features/settings/domain/entities/saved_address.dart';
import 'package:aajhee/src/utils/utils.dart';

class UserAddressService {
  UserAddressService._();
  static final UserAddressService instance = UserAddressService._();

  Dio get _dio => AppConfig.dio;

  String _path(String addressId) => '/api/user/addresses/$addressId';

  SavedAddress _parseAddress(Map<String, dynamic> data) {
    final addressJson = data['address'] ?? data;
    return SavedAddress.fromJson(addressJson as Map<String, dynamic>);
  }

  Map<String, dynamic> _addressPayload({
    required String street,
    required String houseNumber,
    required String postalCode,
    required String city,
    required double latitude,
    required double longitude,
    required String formattedAddress,
    required bool isDefault,
    String? county,
  }) {
    return {
      'street': street,
      'houseNumber': houseNumber,
      'postalCode': postalCode,
      'city': city,
      if (county != null && county.isNotEmpty) 'county': county,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'formattedAddress': formattedAddress,
    };
  }

  FutureEither<SavedAddress> createAddress({
    required String street,
    required String houseNumber,
    required String postalCode,
    required String city,
    required double latitude,
    required double longitude,
    required String formattedAddress,
    required bool isDefault,
    String? county,
  }) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/user/addresses',
        data: _addressPayload(
          street: street,
          houseNumber: houseNumber,
          postalCode: postalCode,
          city: city,
          latitude: latitude,
          longitude: longitude,
          formattedAddress: formattedAddress,
          isDefault: isDefault,
          county: county,
        ),
      );

      return _parseAddress(response.data!);
    }, requiresNetwork: true);
  }

  FutureEither<SavedAddress> updateAddress({
    required String id,
    required String street,
    required String houseNumber,
    required String postalCode,
    required String city,
    required double latitude,
    required double longitude,
    required String formattedAddress,
    required bool isDefault,
    String? county,
  }) async {
    return runTask(() async {
      final response = await _dio.put<Map<String, dynamic>>(
        _path(id),
        data: _addressPayload(
          street: street,
          houseNumber: houseNumber,
          postalCode: postalCode,
          city: city,
          latitude: latitude,
          longitude: longitude,
          formattedAddress: formattedAddress,
          isDefault: isDefault,
          county: county,
        ),
      );

      return _parseAddress(response.data!);
    }, requiresNetwork: true);
  }

  FutureEither<SavedAddress> setDefaultAddress(String id) async {
    return runTask(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        _path(id),
        data: {'isDefault': true},
      );

      return _parseAddress(response.data!);
    }, requiresNetwork: true);
  }

  FutureEither<void> deleteAddress(String id) async {
    return runTask(() async {
      await _dio.delete<void>(_path(id));
    }, requiresNetwork: true);
  }
}
