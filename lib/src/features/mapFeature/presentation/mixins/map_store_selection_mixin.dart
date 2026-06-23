import 'package:flutter/material.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_controller_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/mixins/map_marker_mixin.dart';
import 'package:goluto/src/features/mapFeature/presentation/widgets/map_store_carousel.dart';
import 'package:goluto/src/features/shared/data/dummy_berlin_items.dart';

mixin MapStoreSelectionMixin<T extends StatefulWidget>
    on State<T>, MapControllerMixin<T>, MapMarkerMixin<T> {
  @override
  late final List<ItemModel> mapStores = dummyBerlinItems;
  final ScrollController storeCarouselController = ScrollController();

  @override
  int selectedStoreIndex = 0;

  @override
  void dispose() {
    storeCarouselController.dispose();
    super.dispose();
  }

  Future<void> selectStore(int index, {bool fromMarker = false}) async {
    if (index < 0 || index >= mapStores.length) return;

    setState(() {
      selectedStoreIndex = index;
      ensureSelectedMarkerIconsLoaded(index);
    });

    await focusMapOnStore(mapStores[selectedStoreIndex].position);

    if (fromMarker) {
      MapStoreCarousel.scrollToIndex(storeCarouselController, index);
    }
  }
}
