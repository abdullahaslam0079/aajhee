import 'package:flutter/material.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/mapFeature/presentation/utils/discount_marker_icon_renderer.dart';
import 'package:aajhee/src/features/mapFeature/presentation/utils/map_branch_extensions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerTheme {
  const MapMarkerTheme({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.onSurface,
    required this.outlineVariant,
    required this.brightness,
    required this.devicePixelRatio,
    this.labelStyle,
  });

  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color onSurface;
  final Color outlineVariant;
  final Brightness brightness;
  final double devicePixelRatio;
  final TextStyle? labelStyle;

  String get cacheKey =>
      '${primary.toARGB32()}-${onPrimary.toARGB32()}-${surface.toARGB32()}-${onSurface.toARGB32()}-${outlineVariant.toARGB32()}-${brightness.name}';
}

class MapMarkerIconManager {
  MapMarkerIconManager({
    required this.branches,
    required this.onIconsUpdated,
  });

  final List<MapBranchModel> branches;
  final VoidCallback onIconsUpdated;

  final Map<String, BitmapDescriptor> _iconCache = {};
  final Set<String> _iconLoading = {};
  String? _themeKey;

  void handleThemeChange(MapMarkerTheme theme) {
    if (_themeKey == theme.cacheKey) return;
    _themeKey = theme.cacheKey;
    _iconCache.clear();
    _iconLoading.clear();
    preloadIcons(theme);
  }

  Set<Marker> buildMarkers({
    required int selectedIndex,
    required ValueChanged<int> onMarkerTap,
  }) {
    return branches.asMap().entries.map((entry) {
      final index = entry.key;
      final branch = entry.value;
      final isSelected = index == selectedIndex;
      final pinLabel = branch.mapPinLabel;
      final iconKey = _iconKey(pinLabel, isSelected);
      final icon = _iconCache[iconKey];
      final category = branch.categoryName.trim();

      return Marker(
        markerId: MarkerId(branch.id.toString()),
        position: branch.mapPosition,
        anchor: const Offset(0.5, 1),
        icon: icon ??
            BitmapDescriptor.defaultMarkerWithHue(
              isSelected
                  ? BitmapDescriptor.hueRose
                  : BitmapDescriptor.hueViolet,
            ),
        infoWindow: InfoWindow(
          title: branch.displayName,
          snippet: category.isNotEmpty ? category : null,
          onTap: () => onMarkerTap(index),
        ),
        onTap: () => onMarkerTap(index),
      );
    }).toSet();
  }

  void preloadIcons(MapMarkerTheme theme) {
    final labels = branches.map((b) => b.mapPinLabel).toSet();
    for (final label in labels) {
      _ensureIconLoaded(theme, label, selected: false);
      _ensureIconLoaded(theme, label, selected: true);
    }
  }

  void ensureSelectedIconsLoaded(MapMarkerTheme theme, int selectedIndex) {
    final branch = branches[selectedIndex];
    final label = branch.mapPinLabel;
    _ensureIconLoaded(theme, label, selected: true);
    _ensureIconLoaded(theme, label, selected: false);
  }

  void _ensureIconLoaded(
    MapMarkerTheme theme,
    String label, {
    required bool selected,
  }) {
    final key = _iconKey(label, selected);
    if (_iconCache.containsKey(key) || _iconLoading.contains(key)) return;

    _iconLoading.add(key);

    DiscountMarkerIconRenderer.render(
      label: label,
      selected: selected,
      devicePixelRatio: theme.devicePixelRatio,
      primaryColor: theme.primary,
      onPrimaryColor: theme.onPrimary,
      backgroundColor: theme.surface,
      textColor: theme.onSurface,
      borderColor: theme.outlineVariant,
      labelStyle: theme.labelStyle,
    ).then((bitmap) {
      _iconCache[key] = bitmap;
      _iconLoading.remove(key);
      onIconsUpdated();
    }).catchError((_) {
      _iconLoading.remove(key);
      onIconsUpdated();
    });
  }

  String _iconKey(String label, bool selected) {
    return '$label-${selected ? 's' : 'n'}';
  }
}
