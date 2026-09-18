import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_provider.g.dart';

class LocationState {
  const LocationState({
    this.address,
    this.isLoading = false,
    this.errorMessage,
  });

  final String? address;
  final bool isLoading;
  final String? errorMessage;

  LocationState copyWith({
    String? address,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationState(
      address: address ?? this.address,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class Location extends _$Location {
  @override
  LocationState build() => const LocationState();

  Future<String> _positionToAddress(Position position) async {
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) {
      return 'Lat ${position.latitude}, Lng ${position.longitude}';
    }

    final place = placemarks.first;
    final parts = <String>[
      if ((place.street ?? '').trim().isNotEmpty) place.street!.trim(),
      if ((place.subLocality ?? '').trim().isNotEmpty) place.subLocality!.trim(),
      if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
      if ((place.administrativeArea ?? '').trim().isNotEmpty)
        place.administrativeArea!.trim(),
      if ((place.country ?? '').trim().isNotEmpty) place.country!.trim(),
    ];

    if (parts.isEmpty) {
      return 'Lat ${position.latitude}, Lng ${position.longitude}';
    }

    return parts.join(', ');
  }

  Future<Position> determinePosition() async {
    return Geolocator.getCurrentPosition();
  }

  Future<String> determineAddress() async {
    final position = await determinePosition();
    debugPrint('position::::::::: $position');
    return _positionToAddress(position);
  }

  Future<void> ensureLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Location services are disabled.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Location permission denied.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      String locationText =
          'Lat ${position.latitude}, Lng ${position.longitude}';
      try {
        locationText = await _positionToAddress(position);
      } catch (_) {}
      debugPrint('User location: $locationText');

      state = state.copyWith(address: locationText, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to get location: $e',
      );
    }
  }
}
