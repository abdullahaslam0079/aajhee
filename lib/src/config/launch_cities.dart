import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Launch / coverage cities for Aajhee.
///
/// Edit [enabledCities] to add Karachi, Islamabad, etc. This is the single
/// source of truth for map defaults and address UI hints. Same-day delivery
/// uses a generic same-city rule from the API and does not hardcode cities.
class LaunchCity {
  const LaunchCity({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final double latitude;
  final double longitude;

  LatLng get center => LatLng(latitude, longitude);
}

/// Currently enabled markets — add cities here as Aajhee expands.
const List<LaunchCity> enabledCities = [
  LaunchCity(name: 'Lahore', latitude: 31.5204, longitude: 74.3587),
];

LaunchCity get primaryLaunchCity => enabledCities.first;

String get primaryCityName => primaryLaunchCity.name;

String cityHintExample() {
  if (enabledCities.length == 1) return 'e.g. ${enabledCities.first.name}';
  final names = enabledCities.map((c) => c.name).join(', ');
  return 'e.g. $names';
}

String addressSearchEmptyHint() {
  if (enabledCities.length == 1) {
    return 'No addresses found. Try a street name in ${enabledCities.first.name}.';
  }
  final names = enabledCities.map((c) => c.name).join(', ');
  return 'No addresses found. Try a street name in $names.';
}

String labelSameDayDelivery(String? city) {
  final cleaned = city?.trim() ?? '';
  if (cleaned.isEmpty) return 'Same-day delivery';
  return 'Same-day delivery in $cleaned';
}
