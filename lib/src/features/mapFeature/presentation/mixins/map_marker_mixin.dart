import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/mapFeature/presentation/utils/map_marker_icon_manager.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

mixin MapMarkerMixin<T extends StatefulWidget> on State<T> {
  List<MapBranchModel> get mapBranches;
  int get selectedStoreIndex;

  MapMarkerIconManager? _markerIconManager;
  int? _cachedBranchesHash;
  bool _preloadScheduled = false;

  MapMarkerIconManager get markerIconManager {
    final branches = mapBranches;
    final hash = Object.hashAll(branches.map((branch) => branch.id));
    final recreated =
        _markerIconManager == null || _cachedBranchesHash != hash;
    if (recreated) {
      _cachedBranchesHash = hash;
      _markerIconManager = MapMarkerIconManager(
        branches: branches,
        onIconsUpdated: _handleMarkerIconsUpdated,
      );
      // Branches often arrive after didChangeDependencies. Without this,
      // the new manager keeps empty icon cache and falls back to default pins.
      _scheduleIconPreload();
    }
    return _markerIconManager!;
  }

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

  Set<Marker> buildMapMarkers({
    required ValueChanged<int> onMarkerTap,
    int? selectedIndex,
  }) {
    return markerIconManager.buildMarkers(
      selectedIndex: selectedIndex ?? selectedStoreIndex,
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

  void _scheduleIconPreload() {
    if (_preloadScheduled) return;
    _preloadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadScheduled = false;
      if (!mounted) return;
      final manager = _markerIconManager;
      if (manager == null || manager.branches.isEmpty) return;
      manager.handleThemeChange(markerTheme);
    });
  }

  void _handleMarkerIconsUpdated() {
    if (!mounted) return;
    setState(() {});
  }
}
