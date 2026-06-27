import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/features/mapFeature/presentation/widgets/map_store_card.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class MapStoreCarousel extends StatelessWidget {
  const MapStoreCarousel({
    super.key,
    required this.branches,
    required this.selectedIndex,
    required this.scrollController,
    required this.onStoreSelected,
  });

  final List<MapBranchModel> branches;
  final int selectedIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onStoreSelected;

  static void scrollToIndex(ScrollController controller, int index) {
    final offset = MapConstants.carouselPadding +
        index *
            (MapConstants.storeCardWidth + MapConstants.carouselSeparator);

    if (!controller.hasClients) return;
    controller.animateTo(
      offset,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      height: MapConstants.carouselHeight,
      width: double.infinity,
      
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
              controller: scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: MapConstants.carouselPadding,
              ),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) => MapStoreCard(
                branch: branches[index],
                isSelected: index == selectedIndex,
                onTap: () => onStoreSelected(index),
              ),
              separatorBuilder: (_, __) => SizedBox(width: AppSpacing.ms),
              itemCount: branches.length,
            ),
          ),
        ],
      ),
    );
  }
}
