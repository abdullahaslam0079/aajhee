import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Matches the [BottomAppBar] content height in [BottomNavigationBarScreen].
const double kBottomNavBarHeight = 74;

/// Floating bottom nav horizontal inset from screen edges.
const double kBottomNavBarHorizontalMargin = 16;

/// Floating bottom nav gap above the safe-area bottom edge.
const double kBottomNavBarBottomMargin = 16;

/// Corner radius of the floating bottom navigation bar.
const double kBottomNavBarBorderRadius = 28;

abstract final class MapConstants {
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(52.5200, 13.4050),
    zoom: 12.4746,
  );

  static const double storeCardWidth = 305;
  static const double carouselSeparator = 12;
  static const double carouselPadding = 12;
  static const double carouselHeight = 220;
  static const double mapControlsGap = 10;
  static const double selectedStoreZoom = 15.2;
  static const double currentLocationZoom = 16;

  static const double bottomNavInset =
      kBottomNavBarHeight + kBottomNavBarBottomMargin;

  static double carouselBottomOffset(BuildContext context) =>
      carouselHeight + bottomNavInset;

  static double mapControlsBottomOffset(BuildContext context) =>
      carouselBottomOffset(context) + mapControlsGap;
}
