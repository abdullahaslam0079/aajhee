import 'package:goluto/src/features/mapFeature/presentation/utils/map_marker_icon_manager.dart';
import 'package:goluto/src/features/shared/data/dummy_berlin_items.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

mixin MapMarkerMixin<T extends StatefulWidget> on State<T> {
  List<ItemModel> get mapStores;
  int get selectedStoreIndex;

  MapMarkerIconManager? _markerIconManager;

  MapMarkerIconManager get markerIconManager =>
      _markerIconManager ??= MapMarkerIconManager(
        stores: mapStores,
        onIconsUpdated: _handleMarkerIconsUpdated,
      );

  MapMarkerTheme get markerTheme {
    final theme = context.theme;
    final cs = theme.colorScheme;
    return MapMarkerTheme(
      primary: cs.primary,
      onPrimary: cs.onPrimary,
      surface: cs.surface,
      onSurface: cs.onSurface,
      outlineVariant: cs.outlineVariant,
      brightness: cs.brightness,
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      labelStyle: theme.textTheme.labelLarge,
    );
  }

  Set<Marker> buildMapMarkers({required ValueChanged<int> onMarkerTap}) {
    return markerIconManager.buildMarkers(
      selectedIndex: selectedStoreIndex,
      onMarkerTap: onMarkerTap,
    );
  }

  void ensureSelectedMarkerIconsLoaded(int index) {
    markerIconManager.ensureSelectedIconsLoaded(markerTheme, index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    markerIconManager.handleThemeChange(markerTheme);
  }

  void _handleMarkerIconsUpdated() {
    if (!mounted) return;
    setState(() {});
  }
}
