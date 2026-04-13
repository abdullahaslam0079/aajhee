import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:goluto/src/features/shared/data/dummy_berlin_items.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(52.5200, 13.4050),
    zoom: 12.4746,
  );

  final Completer<GoogleMapController> _mapController = Completer();
  final ScrollController _cardsController = ScrollController();

  late final List<ItemModel> _stores = dummyBerlinItems;
  int _selectedStoreIndex = 0;

  final Map<String, BitmapDescriptor> _markerIconCache = {};
  final Set<String> _markerIconLoading = {};
  String? _markerThemeKey;

  Set<Marker> get _markers {
    return _stores.asMap().entries.map((entry) {
      final index = entry.key;
      final store = entry.value;
      final isSelected = index == _selectedStoreIndex;
      final iconKey = _markerIconKey(store.discountPercent, isSelected);
      final icon = _markerIconCache[iconKey];
      if (icon == null) {
        _ensureMarkerIconLoaded(store.discountPercent, isSelected);
      }

      return Marker(
        markerId: MarkerId(store.id),
        position: store.position,
        icon: icon ??
            BitmapDescriptor.defaultMarkerWithHue(
              isSelected
                  ? BitmapDescriptor.hueRose
                  : BitmapDescriptor.hueViolet,
            ),
        infoWindow: InfoWindow(
          title: store.name,
          snippet: '${store.discountPercent}% off • ${store.category}',
          onTap: () => _selectStore(index, fromMarker: true),
        ),
        onTap: () => _selectStore(index, fromMarker: true),
      );
    }).toSet();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cs = context.theme.colorScheme;
    final newThemeKey =
        '${cs.primary.value}-${cs.onPrimary.value}-${cs.surface.value}-${cs.onSurface.value}-${cs.outlineVariant.value}-${cs.brightness.name}';
    if (_markerThemeKey == newThemeKey) return;
    _markerThemeKey = newThemeKey;
    _markerIconCache.clear();
    _markerIconLoading.clear();
    _preloadMarkerIcons();
  }

  @override
  void dispose() {
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            onMapCreated: (controller) {
              if (!_mapController.isCompleted)
                _mapController.complete(controller);
            },
          ),

          // Positioned(
          //   top: 92,
          //   left: 0,
          //   right: 0,
          //   child: Center(
          //     child: ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: const Color(0xFFE6007E),
          //         foregroundColor: Colors.white,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30),
          //         ),
          //         elevation: 4,
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 24,
          //           vertical: 12,
          //         ),
          //       ),
          //       onPressed: () {},
          //       child: const Text(
          //         'Search this area',
          //         style: TextStyle(fontWeight: FontWeight.w700),
          //       ),
          //     ),
          //   ),
          // ),
          Positioned(
            right: AppSpacing.ms.w,
            bottom: 230,
            child: Column(
              children: [
                _mapActionButton(
                  heroTag: 'zoomIn',
                  icon: Icons.add,
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 8),
                _mapActionButton(
                  heroTag: 'zoomOut',
                  icon: Icons.remove,
                  onPressed: _zoomOut,
                ),
                const SizedBox(height: 8),
                _mapActionButton(
                  heroTag: 'location',
                  icon: Icons.my_location,
                  onPressed: _focusCurrentLocation,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _bottomPanel(colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _bottomPanel(ColorScheme colorScheme) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppBorders.bottomSheet,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 38,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: AppBorders.full,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: ListView.separated(
              controller: _cardsController,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) =>
                  _storeCard(index, _stores[index], colorScheme),
              separatorBuilder: (_, __) => SizedBox(width: AppSpacing.ms.w),
              itemCount: _stores.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeCard(int index, ItemModel store, ColorScheme colorScheme) {
    final isSelected = index == _selectedStoreIndex;
    final textTheme = context.theme.textTheme;

    return Container(
      width: 305,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppBorders.md,
        border: isSelected
            ? Border.all(color: colorScheme.primary, width: 2)
            : Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _selectStore(index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 105,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                image: const DecorationImage(
                    image: NetworkImage(
                      'https://plus.unsplash.com/premium_photo-1664392147011-2a720f214e01?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZHVjdHxlbnwwfHwwfHx8MA%3D%3D',
                    ),
                    fit: BoxFit.cover),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: AppBorders.full,
                      ),
                      child: Text(
                        store.eta,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: AppBorders.full,
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer,
                            size: 15,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${store.discountPercent}% off',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(
                store.name,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                children: [
                  Text(
                    store.address,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStore(int index, {bool fromMarker = false}) async {
    if (index < 0 || index >= _stores.length) return;

    setState(() => _selectedStoreIndex = index);

    await _focusSelectedStore();

    if (!fromMarker) return;
    _scrollToCard(index);
  }

  Future<void> _focusSelectedStore() async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    final store = _stores[_selectedStoreIndex];
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: store.position, zoom: 15.2),
      ),
    );
  }

  Future<void> _zoomIn() async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> _focusCurrentLocation() async {
    if (!_mapController.isCompleted) return;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Location services are disabled.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationError('Location permission denied.');
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
          ),
          
        );
      } on TimeoutException {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        _showLocationError('Could not determine current location.');
        return;
      }

      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16,
        ),
      );
    } catch (e) {
      _showLocationError('Failed to get location: $e');
    }
  }

  void _showLocationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _mapActionButton({
    required String heroTag,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final colorScheme = context.theme.colorScheme;
    return FloatingActionButton.small(
      heroTag: heroTag,
      backgroundColor: colorScheme.surface,
      elevation: 3,
      onPressed: onPressed,
      child: Icon(icon, color: colorScheme.onSurface),
    );
  }

  void _scrollToCard(int index) {
    const cardWidth = 305.0;
    const separator = 12.0;
    const listPadding = 12.0;
    final offset = listPadding + index * (cardWidth + separator);

    if (!_cardsController.hasClients) return;
    _cardsController.animateTo(
      offset,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  String _markerIconKey(int discountPercent, bool selected) {
    return '$discountPercent-${selected ? 's' : 'n'}';
  }

  void _preloadMarkerIcons() {
    final discounts = _stores.map((s) => s.discountPercent).toSet();
    for (final d in discounts) {
      _ensureMarkerIconLoaded(d, false);
      _ensureMarkerIconLoaded(d, true);
    }
  }

  void _ensureMarkerIconLoaded(int discountPercent, bool selected) {
    final key = _markerIconKey(discountPercent, selected);
    if (_markerIconCache.containsKey(key)) return;
    if (_markerIconLoading.contains(key)) return;
    _markerIconLoading.add(key);
    final cs = context.theme.colorScheme;

    _DiscountMarkerIconRenderer.render(
      discountPercent: discountPercent,
      selected: selected,
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      primaryColor: cs.primary,
      onPrimaryColor: cs.onPrimary,
      backgroundColor: cs.surface,
      textColor: cs.onSurface,
      borderColor: cs.outlineVariant,
      labelStyle: context.theme.textTheme.labelLarge,
    ).then((bitmap) {
      if (!mounted) return;
      setState(() {
        _markerIconCache[key] = bitmap;
        _markerIconLoading.remove(key);
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _markerIconLoading.remove(key));
    });
  }
}

class _DiscountMarkerIconRenderer {
  static Future<BitmapDescriptor> render({
    required int discountPercent,
    required bool selected,
    required double devicePixelRatio,
    required Color primaryColor,
    required Color onPrimaryColor,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    TextStyle? labelStyle,
  }) async {
    final text = '$discountPercent% off';
    final scale = devicePixelRatio.clamp(1.0, 3.0);

    final textStyle = (labelStyle ?? const TextStyle()).copyWith(
      color: textColor,
      fontWeight: FontWeight.w800,
      fontSize: ((labelStyle?.fontSize ?? 14) * scale),
    );

    final iconStyle = TextStyle(
      fontFamily: 'MaterialIcons',
      fontSize: 14 * scale,
      color: onPrimaryColor,
    );

    final tp = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final iconSize = 22.0 * scale;
    final paddingH = 12.0 * scale;
    final paddingV = 8.0 * scale;
    final gap = 8.0 * scale;

    final pillWidth = paddingH + iconSize + gap + tp.width + paddingH;
    final pillHeight = (iconSize + paddingV * 2).clamp(
      34.0 * scale,
      46.0 * scale,
    );

    final shadowPad = 10.0 * scale;
    final totalWidth = pillWidth + shadowPad * 2;
    final totalHeight = pillHeight + shadowPad * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(shadowPad, shadowPad, pillWidth, pillHeight),
      Radius.circular(18.0 * scale),
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: selected ? 0.18 : 0.14)
      ..maskFilter = ui.MaskFilter.blur(
        ui.BlurStyle.normal,
        8.0 * scale,
      );

    canvas.save();
    canvas.translate(0, 2.0 * scale);
    canvas.drawRRect(pillRect, shadowPaint);
    canvas.restore();

    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(pillRect, bgPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (selected ? 2.0 : 1.0) * scale
      ..color = selected ? primaryColor : borderColor;
    canvas.drawRRect(pillRect, borderPaint);

    final circleCenter = Offset(
      shadowPad + paddingH + iconSize / 2,
      shadowPad + pillHeight / 2,
    );
    final circlePaint = Paint()..color = primaryColor;
    canvas.drawCircle(circleCenter, iconSize / 2, circlePaint);

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.local_offer.codePoint),
        style: iconStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      Offset(
        circleCenter.dx - iconPainter.width / 2,
        circleCenter.dy - iconPainter.height / 2,
      ),
    );

    tp.paint(
      canvas,
      Offset(
        shadowPad + paddingH + iconSize + gap,
        shadowPad + (pillHeight - tp.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      totalWidth.ceil(),
      totalHeight.ceil(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = Uint8List.view(byteData!.buffer);
    return BitmapDescriptor.fromBytes(bytes);
  }
}
