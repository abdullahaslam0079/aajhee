import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:goluto/src/features/settings/data/services/address_geocoding_service.dart';
import 'package:goluto/src/features/settings/domain/entities/saved_address.dart';
import 'package:goluto/src/imports/packages_imports.dart';

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

final addressGeocodingServiceProvider = Provider<AddressGeocodingService>(
  (ref) => AddressGeocodingService(),
);

final savedAddressesProvider =
    StateNotifierProvider<SavedAddressesNotifier, SavedAddressesState>(
  (ref) => SavedAddressesNotifier(
    geocodingService: ref.read(addressGeocodingServiceProvider),
  ),
);

class SavedAddressesNotifier extends StateNotifier<SavedAddressesState> {
  SavedAddressesNotifier({required AddressGeocodingService geocodingService})
      : _geocodingService = geocodingService,
        super(const SavedAddressesState(isLoading: true)) {
    _load();
  }

  static const _storageKey = 'saved_addresses';

  final AddressGeocodingService _geocodingService;
  SharedPreferences? _prefs;

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
    final address = SavedAddress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      street: street.trim(),
      houseNumber: houseNumber.trim(),
      postalCode: postalCode.trim(),
      city: city.trim(),
      latitude: geocoded.latitude,
      longitude: geocoded.longitude,
      formattedAddress: geocoded.formattedAddress,
      isDefault: isFirst,
    );

    await _persist([...state.addresses, address]);
  }

  Future<void> removeAddress(String id) async {
    final updated = state.addresses.where((a) => a.id != id).toList();
    if (updated.isEmpty) {
      await _persist([]);
      return;
    }

    final hadDefault = state.addresses.any((a) => a.id == id && a.isDefault);
    if (hadDefault) {
      updated[0] = updated.first.copyWith(isDefault: true);
    }

    await _persist(updated);
  }

  Future<void> setDefault(String id) async {
    final updated = state.addresses
        .map((a) => a.copyWith(isDefault: a.id == id))
        .toList();
    await _persist(updated);
  }
}
