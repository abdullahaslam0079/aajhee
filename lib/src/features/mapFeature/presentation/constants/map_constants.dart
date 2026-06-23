import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract final class MapConstants {
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(52.5200, 13.4050),
    zoom: 12.4746,
  );

  static const double storeCardWidth = 305;
  static const double carouselSeparator = 12;
  static const double carouselPadding = 12;
  static const double selectedStoreZoom = 15.2;
  static const double currentLocationZoom = 16;
  static const double mapControlsBottomOffset = 230;
}
