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
      '${primary.value}-${onPrimary.value}-${surface.value}-${onSurface.value}-${outlineVariant.value}-${brightness.name}';
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
      final iconKey = _iconKey(branch.discountPercentInt, isSelected);
      final icon = _iconCache[iconKey];

      return Marker(
        markerId: MarkerId(branch.id.toString()),
        position: branch.mapPosition,
        anchor: const Offset(0.5, 1.0),
        icon: icon ??
            BitmapDescriptor.defaultMarkerWithHue(
              isSelected
                  ? BitmapDescriptor.hueRose
                  : BitmapDescriptor.hueViolet,
            ),
        infoWindow: InfoWindow(
          title: branch.displayName,
          snippet:
              '${branch.discountPercentInt}% off • ${branch.categoryName}',
          onTap: () => onMarkerTap(index),
        ),
        onTap: () => onMarkerTap(index),
      );
    }).toSet();
  }

  void preloadIcons(MapMarkerTheme theme) {
    final discounts = branches.map((b) => b.discountPercentInt).toSet();
    for (final discount in discounts) {
      _ensureIconLoaded(theme, discount, selected: false);
      _ensureIconLoaded(theme, discount, selected: true);
    }
  }

  void ensureSelectedIconsLoaded(MapMarkerTheme theme, int selectedIndex) {
    final branch = branches[selectedIndex];
    _ensureIconLoaded(theme, branch.discountPercentInt, selected: true);
    _ensureIconLoaded(theme, branch.discountPercentInt, selected: false);
  }

  void _ensureIconLoaded(
    MapMarkerTheme theme,
    int discountPercent, {
    required bool selected,
  }) {
    final key = _iconKey(discountPercent, selected);
    if (_iconCache.containsKey(key) || _iconLoading.contains(key)) return;

    _iconLoading.add(key);

    DiscountMarkerIconRenderer.render(
      discountPercent: discountPercent,
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

  String _iconKey(int discountPercent, bool selected) {
    return '$discountPercent-${selected ? 's' : 'n'}';
  }
}
