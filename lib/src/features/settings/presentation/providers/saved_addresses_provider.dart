import 'dart:convert';

import 'package:aajhee/src/features/settings/data/services/address_geocoding_service.dart';
import 'package:aajhee/src/features/settings/data/services/user_address_service.dart';
import 'package:aajhee/src/features/settings/domain/entities/saved_address.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_addresses_provider.g.dart';

class SavedAddressesState {
  const SavedAddressesState({
    this.addresses = const [],
    this.isLoading = false,
  });

  final List<SavedAddress> addresses;
  final bool isLoading;

  SavedAddressesState copyWith({
    List<SavedAddress>? addresses,
    bool? isLoading,
  }) {
    return SavedAddressesState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  SavedAddress? get selectedAddress {
    if (addresses.isEmpty) return null;
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.first;
  }
}

@Riverpod(keepAlive: true)
AddressGeocodingService addressGeocodingService(Ref ref) {
  return AddressGeocodingService();
}

@Riverpod(keepAlive: true)
UserAddressService userAddressService(Ref ref) {
  return UserAddressService.instance;
}

@Riverpod(keepAlive: true)
class SavedAddresses extends _$SavedAddresses {
  static const _storageKey = 'saved_addresses';

  SharedPreferences? _prefs;
  Future<void> _initialLoad = Future.value();

  AddressGeocodingService get _geocodingService =>
      ref.read(addressGeocodingServiceProvider);

  UserAddressService get _addressService =>
      ref.read(userAddressServiceProvider);

  @override
  SavedAddressesState build() {
    _initialLoad = _load();
    return const SavedAddressesState(isLoading: true);
  }

  Future<void> ensureLoaded() => _initialLoad;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _load() async {
    try {
      final prefs = await _preferences;
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        state = const SavedAddressesState(addresses: []);
        return;
      }

      final decoded = jsonDecode(raw) as List<dynamic>;
      final addresses = decoded
          .map((entry) => SavedAddress.fromJson(entry as Map<String, dynamic>))
          .toList();

      state = SavedAddressesState(addresses: addresses);
    } catch (_) {
      state = const SavedAddressesState(addresses: []);
    }
  }

  Future<void> _persist(List<SavedAddress> addresses) async {
    final prefs = await _preferences;
    final encoded = jsonEncode(addresses.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
    state = SavedAddressesState(addresses: addresses);
  }

  Future<void> syncFromApi(List<SavedAddress> addresses) async {
    await _persist(addresses);
  }

  Future<GeocodedAddress> validateAddress({
    required String street,
    required String houseNumber,
    required String postalCode,
    required String city,
  }) {
    return _geocodingService.validateAndGeocode(
      street: street,
      houseNumber: houseNumber,
      postalCode: postalCode,
      city: city,
    );
  }

  Future<void> addAddress({
    required String street,
    required String houseNumber,
    required String postalCode,
    required String city,
    required GeocodedAddress geocoded,
  }) async {
    final isFirst = state.addresses.isEmpty;
    final result = await _addressService.createAddress(
      street: street.trim(),
      houseNumber: houseNumber.trim(),
      postalCode: postalCode.trim(),
      city: city.trim(),
      latitude: geocoded.latitude,
      longitude: geocoded.longitude,
      formattedAddress: geocoded.formattedAddress,
      isDefault: isFirst,
      county: geocoded.county,
    );

    await result.fold(
      (failure) async => throw AddressValidationException(failure.message),
      (address) async {
        await _persist([...state.addresses, address]);
      },
    );
  }

  Future<void> updateAddress({
    required String id,
    required String street,
    required String houseNumber,
    required String postalCode,
    required String city,
    required GeocodedAddress geocoded,
  }) async {
    final existing = state.addresses.firstWhere((a) => a.id == id);
    final result = await _addressService.updateAddress(
      id: id,
      street: street.trim(),
      houseNumber: houseNumber.trim(),
      postalCode: postalCode.trim(),
      city: city.trim(),
      latitude: geocoded.latitude,
      longitude: geocoded.longitude,
      formattedAddress: geocoded.formattedAddress,
      isDefault: existing.isDefault,
      county: geocoded.county,
    );

    await result.fold(
      (failure) async => throw AddressValidationException(failure.message),
      (updated) async {
        final addresses = state.addresses
            .map((a) => a.id == id ? updated : a)
            .toList();
        await _persist(addresses);
      },
    );
  }

  Future<void> removeAddress(String id) async {
    final result = await _addressService.deleteAddress(id);

    await result.fold(
      (failure) async => throw AddressValidationException(failure.message),
      (_) async {
        final updated = state.addresses.where((a) => a.id != id).toList();
        if (updated.isEmpty) {
          await _persist([]);
          return;
        }

        final hadDefault =
            state.addresses.any((a) => a.id == id && a.isDefault);
        if (hadDefault) {
          updated[0] = updated.first.copyWith(isDefault: true);
        }

        await _persist(updated);
      },
    );
  }

  Future<void> setDefault(String id) async {
    final result = await _addressService.setDefaultAddress(id);

    await result.fold(
      (failure) async => throw AddressValidationException(failure.message),
      (updated) async {
        final addresses = state.addresses
            .map((a) => a.id == id ? updated : a.copyWith(isDefault: false))
            .toList();
        await _persist(addresses);
      },
    );
  }
}
