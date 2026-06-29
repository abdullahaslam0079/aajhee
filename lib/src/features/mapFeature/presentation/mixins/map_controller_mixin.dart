import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goluto/src/features/mapFeature/presentation/utils/map_camera_actions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

mixin MapControllerMixin<T extends StatefulWidget> on State<T> {
  final Completer<GoogleMapController> mapController = Completer();

  void onMapCreated(GoogleMapController controller) {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
    }
  }

  Future<void> withMapController(
    Future<void> Function(GoogleMapController controller) action,
  ) async {
    if (!mapController.isCompleted) return;
    await action(await mapController.future);
  }

  Future<void> zoomMapIn() => withMapController(MapCameraActions.zoomIn);

  Future<void> zoomMapOut() => withMapController(MapCameraActions.zoomOut);

  Future<void> focusMapOnStore(LatLng position) =>
      withMapController((controller) => MapCameraActions.focusStore(controller, position));

  Future<void> focusMapOnLocation(LatLng position) =>
      withMapController((controller) => MapCameraActions.focusLocation(controller, position));

  Future<void> focusMapOnAddress(LatLng position) =>
      withMapController((controller) => MapCameraActions.focusAddress(controller, position));
}
