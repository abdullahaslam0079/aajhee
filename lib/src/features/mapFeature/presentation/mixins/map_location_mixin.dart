import 'package:flutter/material.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_controller_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/utils/map_location_helper.dart';

mixin MapLocationMixin<T extends StatefulWidget> on State<T>, MapControllerMixin<T> {
  Future<void> focusCurrentLocation() async {
    final result = await MapLocationHelper.getCurrentPosition();
    if (!result.isSuccess) {
      showMapLocationError(result.errorMessage!);
      return;
    }

    await focusMapOnLocation(result.position!);
  }

  void showMapLocationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
