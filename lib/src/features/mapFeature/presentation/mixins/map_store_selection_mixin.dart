import 'package:flutter/material.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_controller_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_marker_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/utils/map_branch_extensions.dart';
import 'package:goluto/src/features/mapFeature/presentation/widgets/map_store_carousel.dart';

mixin MapStoreSelectionMixin<T extends StatefulWidget>
    on State<T>, MapControllerMixin<T>, MapMarkerMixin<T> {
  final ScrollController storeCarouselController = ScrollController();

  @override
  int selectedStoreIndex = 0;

  @override
  void dispose() {
    storeCarouselController.dispose();
    super.dispose();
  }

  Future<void> selectStore(int index, {bool fromMarker = false}) async {
    if (index < 0 || index >= mapBranches.length) return;

    setState(() {
      selectedStoreIndex = index;
      ensureSelectedMarkerIconsLoaded(index);
    });

    await focusMapOnStore(mapBranches[selectedStoreIndex].mapPosition);

    if (fromMarker) {
      MapStoreCarousel.scrollToIndex(storeCarouselController, index);
    }
  }
}
