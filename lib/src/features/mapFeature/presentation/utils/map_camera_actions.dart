import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';

abstract final class MapCameraActions {
  static Future<void> focusStore(
    GoogleMapController controller,
    LatLng position,
  ) {
    return controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: MapConstants.selectedStoreZoom,
        ),
      ),
    );
  }

  static Future<void> focusLocation(
    GoogleMapController controller,
    LatLng position,
  ) {
    return controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        position,
        MapConstants.currentLocationZoom,
      ),
    );
  }

  static Future<void> zoomIn(GoogleMapController controller) {
    return controller.animateCamera(CameraUpdate.zoomIn());
  }

  static Future<void> zoomOut(GoogleMapController controller) {
    return controller.animateCamera(CameraUpdate.zoomOut());
  }
}
