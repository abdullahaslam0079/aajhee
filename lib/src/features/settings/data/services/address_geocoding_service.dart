import 'package:geocoding/geocoding.dart';

class AddressValidationException implements Exception {
  AddressValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeocodedAddress {
  const GeocodedAddress({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  final double latitude;
  final double longitude;
  final String formattedAddress;
}

class AddressGeocodingService {
  Future<GeocodedAddress> validateAndGeocode({
    required String street,
    required String houseNumber,
    required String postalCode,
    required String city,
  }) async {
    final normalizedStreet = street.trim();
    final normalizedHouseNumber = houseNumber.trim();
    final normalizedPostalCode = _normalizePostalCode(postalCode);
    final normalizedCity = city.trim();

    final query =
        '$normalizedStreet $normalizedHouseNumber, $normalizedPostalCode $normalizedCity';

    List<Location> locations;
    try {
      locations = await locationFromAddress(query);
    } catch (_) {
      throw AddressValidationException(
        'Could not look up this address. Please check your details and try again.',
      );
    }

    if (locations.isEmpty) {
      throw AddressValidationException(
        'Address not found. Please verify street, house number, postal code, and city.',
      );
    }

    final location = locations.first;

    List<Placemark> placemarks;
    try {
      placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
    } catch (_) {
      throw AddressValidationException(
        'Unable to verify this address. Please try again.',
      );
    }

    if (placemarks.isEmpty) {
      throw AddressValidationException(
        'Unable to verify this address. Please try again.',
      );
    }

    final place = placemarks.first;
    _verifyPostalCode(normalizedPostalCode, place.postalCode);
    _verifyCity(normalizedCity, place);

    return GeocodedAddress(
      latitude: location.latitude,
      longitude: location.longitude,
      formattedAddress: _formatPlacemark(place),
    );
  }

  void _verifyPostalCode(String input, String? resolved) {
    final resolvedNormalized = _normalizePostalCode(resolved ?? '');
    if (resolvedNormalized.isEmpty) return;

    if (resolvedNormalized != input) {
      throw AddressValidationException(
        'Postal code does not match the verified location.',
      );
    }
  }

  void _verifyCity(String input, Placemark place) {
    final candidates = [
      place.locality,
      place.subLocality,
      place.subAdministrativeArea,
      place.administrativeArea,
    ]
        .whereType<String>()
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toSet();

    if (candidates.isEmpty) return;

    final inputCity = input.toLowerCase();
    final matches = candidates.any(
      (candidate) =>
          candidate.contains(inputCity) || inputCity.contains(candidate),
    );

    if (!matches) {
      throw AddressValidationException(
        'City does not match the verified location.',
      );
    }
  }

  String _normalizePostalCode(String value) {
    return value.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  String _formatPlacemark(Placemark place) {
    final parts = <String>[
      if ((place.street ?? '').trim().isNotEmpty) place.street!.trim(),
      if ((place.postalCode ?? '').trim().isNotEmpty) place.postalCode!.trim(),
      if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
      if ((place.country ?? '').trim().isNotEmpty) place.country!.trim(),
    ];
    return parts.join(', ');
  }
}
