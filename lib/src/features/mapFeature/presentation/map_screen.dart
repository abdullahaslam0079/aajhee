import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_controller_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_location_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_marker_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_store_selection_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/widgets/map_action_button.dart';
import 'package:goluto/src/features/mapFeature/presentation/widgets/map_store_carousel.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with
        MapControllerMixin,
        MapLocationMixin,
        MapMarkerMixin,
        MapStoreSelectionMixin {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final carouselBottomOffset = MapConstants.carouselBottomOffset(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: MapConstants.initialCameraPosition,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: false,
            padding: EdgeInsets.only(bottom: carouselBottomOffset),
            markers: buildMapMarkers(
              onMarkerTap: (index) => selectStore(index, fromMarker: true),
            ),
            onMapCreated: onMapCreated,
          ),
          Positioned(
            right: AppSpacing.ms.w,
            bottom: MapConstants.mapControlsBottomOffset(context),
            child: Column(
              children: [
                MapActionButton(
                  heroTag: 'zoomIn',
                  icon: Icons.add,
                  onPressed: zoomMapIn,
                ),
                const SizedBox(height: 8),
                MapActionButton(
                  heroTag: 'zoomOut',
                  icon: Icons.remove,
                  onPressed: zoomMapOut,
                ),
                const SizedBox(height: 8),
                MapActionButton(
                  heroTag: 'location',
                  icon: Icons.my_location,
                  onPressed: focusCurrentLocation,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 150),
              child: MapStoreCarousel(
                stores: mapStores,
                selectedIndex: selectedStoreIndex,
                scrollController: storeCarouselController,
                onStoreSelected: selectStore,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
