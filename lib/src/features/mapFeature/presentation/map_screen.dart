import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_controller_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_location_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_marker_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_store_selection_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/widgets/map_action_button.dart';
import 'package:goluto/src/features/mapFeature/presentation/widgets/map_store_carousel.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:goluto/src/routing/app_routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with
        MapControllerMixin,
        MapLocationMixin,
        MapMarkerMixin,
        MapStoreSelectionMixin {
  @override
  List<MapBranchModel> get mapBranches =>
      ref.watch(homeFeedProvider).branches;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final feedState = ref.watch(homeFeedProvider);
    final carouselBottomOffset = MapConstants.carouselBottomOffset(context);
    final branches = feedState.branches;
    final isLoading = feedState.isLoading && branches.isEmpty;
    final hasError = feedState.errorMessage != null && branches.isEmpty;
    final selectedIndex = branches.isEmpty
        ? 0
        : selectedStoreIndex.clamp(0, branches.length - 1);

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
            markers: branches.isEmpty
                ? const {}
                : buildMapMarkers(
                    selectedIndex: selectedIndex,
                    onMarkerTap: (index) => selectStore(index),
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
          if (branches.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 150),
                child: MapStoreCarousel(
                  branches: branches,
                  selectedIndex: selectedIndex,
                  scrollController: storeCarouselController,
                  onStoreSelected: selectStore,
                  onViewDetails: (branch) {
                    context.push(AppRoutes.businessStore, extra: branch);
                  },
                ),
              ),
            ),
          if (isLoading)
            const Positioned.fill(child: AppLoading(message: 'Loading stores...')),
          if (hasError)
            Positioned.fill(
              child: ColoredBox(
                color: colorScheme.surface.withValues(alpha: 0.92),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          feedState.errorMessage!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Retry',
                          onPressed: () =>
                              ref.read(homeFeedProvider.notifier).load(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
