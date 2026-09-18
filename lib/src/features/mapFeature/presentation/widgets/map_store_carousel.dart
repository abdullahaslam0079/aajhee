import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/features/mapFeature/presentation/widgets/map_store_card.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class MapStoreCarousel extends StatelessWidget {
  const MapStoreCarousel({
    super.key,
    required this.branches,
    required this.selectedIndex,
    required this.scrollController,
    required this.onStoreSelected,
    required this.onViewDetails,
  });

  final List<MapBranchModel> branches;
  final int selectedIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onStoreSelected;
  final ValueChanged<MapBranchModel> onViewDetails;

  static void scrollToIndex(ScrollController controller, int index) {
    void scroll() {
      if (!controller.hasClients) return;

      final itemStride =
          MapConstants.storeCardWidth + MapConstants.carouselSeparator;
      final cardLeft =
          MapConstants.carouselPadding + index * itemStride;
      final cardCenter = cardLeft + MapConstants.storeCardWidth / 2;
      final viewportCenter = controller.position.viewportDimension / 2;
      final targetOffset = (cardCenter - viewportCenter).clamp(
        controller.position.minScrollExtent,
        controller.position.maxScrollExtent,
      );

      controller.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }

    if (controller.hasClients) {
      scroll();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => scroll());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface.withValues(alpha: 0),
            colorScheme.surface.withValues(alpha: 0.72),
          ],
        ),
      ),
      child: SizedBox(
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
                  color: colorScheme.outlineVariant.withValues(alpha: 0.85),
                  borderRadius: AppBorders.full,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: MapConstants.storeCardHeight +
                  MapConstants.storeCardOuterInset * 2,
              child: ListView.separated(
                controller: scrollController,
                clipBehavior: Clip.none,
                padding: EdgeInsets.fromLTRB(
                  MapConstants.carouselPadding,
                  MapConstants.storeCardOuterInset,
                  MapConstants.carouselPadding,
                  MapConstants.storeCardOuterInset,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (_, index) {
                  final branch = branches[index];
                  return MapStoreCard(
                    branch: branch,
                    isSelected: index == selectedIndex,
                    onTap: () => onStoreSelected(index),
                    onViewDetails: () => onViewDetails(branch),
                  );
                },
                separatorBuilder: (_, __) =>
                    const SizedBox(width: MapConstants.carouselSeparator),
                itemCount: branches.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
