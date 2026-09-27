import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Fixed center pin: pan/zoom the map underneath; pin stays in the middle.
class AddressLocationMapPicker extends StatefulWidget {
  const AddressLocationMapPicker({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onLocationSelected,
    this.enabled = true,
    this.expand = false,
    this.height = 240,
  });

  final double latitude;
  final double longitude;
  final ValueChanged<LatLng> onLocationSelected;
  final bool enabled;
  /// When true, fills parent height (use inside [Expanded]).
  final bool expand;
  final double height;

  @override
  State<AddressLocationMapPicker> createState() =>
      _AddressLocationMapPickerState();
}

class _AddressLocationMapPickerState extends State<AddressLocationMapPicker> {
  GoogleMapController? _controller;
  LatLng _center = const LatLng(52.52, 13.405);
  bool _moving = false;
  bool _ignoreNextIdle = false;

  /// Claim map gestures so a parent [ScrollView] does not steal pans.
  final Set<Factory<OneSequenceGestureRecognizer>> _gestureRecognizers = {
    Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
  };

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.latitude, widget.longitude);
  }

  @override
  void didUpdateWidget(covariant AddressLocationMapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final latChanged = (oldWidget.latitude - widget.latitude).abs() > 0.00001;
    final lngChanged = (oldWidget.longitude - widget.longitude).abs() > 0.00001;
    if (!latChanged && !lngChanged) return;

    _center = LatLng(widget.latitude, widget.longitude);
    _ignoreNextIdle = true;
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        MapConstants.cameraPositionFor(_center, zoom: 16),
      ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    if (!widget.enabled) return;
    _center = position.target;
    if (!_moving) {
      setState(() => _moving = true);
    }
  }

  void _onCameraIdle() {
    if (!widget.enabled) return;
    if (_moving) {
      setState(() => _moving = false);
    }
    if (_ignoreNextIdle) {
      _ignoreNextIdle = false;
      return;
    }
    widget.onLocationSelected(_center);
  }

  Widget _mapStack(ColorScheme cs) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GoogleMap(
          initialCameraPosition: MapConstants.cameraPositionFor(
            _center,
            zoom: 16,
          ),
          onMapCreated: (controller) => _controller = controller,
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
          markers: const {},
          gestureRecognizers: _gestureRecognizers,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          scrollGesturesEnabled: widget.enabled,
          zoomGesturesEnabled: widget.enabled,
          rotateGesturesEnabled: widget.enabled,
          tiltGesturesEnabled: false,
          liteModeEnabled: false,
        ),
        IgnorePointer(
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 120),
            offset: _moving ? const Offset(0, -0.12) : Offset.zero,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 120),
              scale: _moving ? 1.08 : 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 48,
                    color: cs.primary,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final map = ClipRRect(
      borderRadius: AppBorders.lg,
      child: widget.expand
          ? _mapStack(cs)
          : SizedBox(height: widget.height.h, child: _mapStack(cs)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.expand) Expanded(child: map) else map,
        SizedBox(height: AppSpacing.xs.h),
        Text(
          'Slide the map with your finger. The pin stays in the center — stop moving to update the location.',
          style: context.theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
