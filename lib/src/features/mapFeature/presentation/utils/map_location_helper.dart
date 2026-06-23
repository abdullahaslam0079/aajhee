import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocationResult {
  const MapLocationResult.success(this.position) : errorMessage = null;

  const MapLocationResult.failure(this.errorMessage) : position = null;

  final LatLng? position;
  final String? errorMessage;

  bool get isSuccess => position != null;
}

abstract final class MapLocationHelper {
  static Future<MapLocationResult> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const MapLocationResult.failure(
          'Location services are disabled.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const MapLocationResult.failure('Location permission denied.');
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
          ),
        );
      } on TimeoutException {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        return const MapLocationResult.failure(
          'Could not determine current location.',
        );
      }

      return MapLocationResult.success(
        LatLng(position.latitude, position.longitude),
      );
    } catch (e) {
      return MapLocationResult.failure('Failed to get location: $e');
    }
  }
}
