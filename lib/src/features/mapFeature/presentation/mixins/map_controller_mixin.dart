import 'dart:async';

import 'package:aajhee/src/features/mapFeature/presentation/utils/map_camera_actions.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

mixin MapControllerMixin<T extends StatefulWidget> on State<T> {
  final Completer<GoogleMapController> mapController = Completer();
  GoogleMapController? _googleMapController;
  var _mapControllerDisposed = false;

  void onMapCreated(GoogleMapController controller) {
    if (_mapControllerDisposed) {
      controller.dispose();
      return;
    }
    _googleMapController = controller;
    if (!mapController.isCompleted) {
      mapController.complete(controller);
    }
  }

  @override
  void dispose() {
    _mapControllerDisposed = true;
    _googleMapController?.dispose();
    _googleMapController = null;
    super.dispose();
  }

  Future<void> withMapController(
    Future<void> Function(GoogleMapController controller) action,
  ) async {
    if (_mapControllerDisposed || !mapController.isCompleted) return;
    final controller = _googleMapController;
    if (controller == null) return;
    await action(controller);
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
