import 'package:goluto/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:goluto/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:goluto/src/features/home/presentation/utils/category_icons.dart';
import 'package:goluto/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:goluto/src/features/location/presentation/providers/location_provider.dart';
import 'package:goluto/src/features/home/presentation/widgets/category_widget.dart';
import 'package:goluto/src/features/home/presentation/widgets/home_header.dart';
import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    final locationState = ref.watch(locationProvider);
    final savedAddressesState = ref.watch(savedAddressesProvider);
    final homeFeedState = ref.watch(homeFeedProvider);
    final selectedAddress = savedAddressesState.selectedAddress;
    final locationText = selectedAddress?.shortLabel ??
        locationState.address ??
        'Add delivery address';

    final bottomInset = kHomeFeedBottomInset +
        MediaQuery.paddingOf(context).bottom +
        AppSpacing.lg.h;

    final categoryLabels = homeFeedState.categoryLabels;
    final branches = homeFeedState.filteredBranches;

    return Scaffold(
      backgroundColor: kHomeCanvasColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeFeedProvider.notifier).load(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  locationText: locationText,
                  onLocationTap: () => showDeliveryAddressPicker(context, ref),
                  onFavoritesTap: () => context.push(AppRoutes.favorites),
                  onNotificationsTap: () =>
                      context.push(AppRoutes.notifications),
                ),
              ),
              if (homeFeedState.isLoading && homeFeedState.branches.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (homeFeedState.errorMessage != null &&
                  homeFeedState.branches.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _HomeFeedError(
                    message: homeFeedState.errorMessage!,
                    onRetry: () => ref.read(homeFeedProvider.notifier).load(),
                  ),
                )
              else ...[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HomeCategoriesHeaderDelegate(
                    selectedCategoryIndex: homeFeedState.selectedCategoryIndex,
                    categoryLabels: categoryLabels,
                    onCategoryTap: (index) => ref
                        .read(homeFeedProvider.notifier)
                        .selectCategory(index),
                    textTheme: textTheme,
                    backgroundColor: kHomeCanvasColor,
                  ),
                ),
                if (branches.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No branches found in this category.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.sm.w,
                      AppSpacing.lg.h,
                      AppSpacing.sm.w,
                      0,
                    ),
                    sliver: SliverList.separated(
                      itemCount: branches.length,
                      itemBuilder: (context, index) {
                        final branch = branches[index];
                        return BusinessStoreCard(
                          branch: branch,
                          onTap: () {
                            context.push(
                              AppRoutes.businessStore,
                              extra: branch,
                            );
                          },
                        );
                      },
                      separatorBuilder: (_, __) =>
                          SizedBox(height: AppSpacing.md.h),
                    ),
                  ),
              ],
              SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeFeedError extends StatelessWidget {
  const _HomeFeedError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _HomeCategoriesHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HomeCategoriesHeaderDelegate({
    required this.selectedCategoryIndex,
    required this.categoryLabels,
    required this.onCategoryTap,
    required this.textTheme,
    required this.backgroundColor,
  });

  final int selectedCategoryIndex;
  final List<String> categoryLabels;
  final ValueChanged<int> onCategoryTap;
  final TextTheme textTheme;
  final Color backgroundColor;

  static const double _chipRowHeight = 44;

  double get _extent =>
      AppSpacing.sm.h + 24.h + AppSpacing.sm.h + _chipRowHeight.h;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.sm.w,
          AppSpacing.sm.h,
          AppSpacing.sm.w,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            SizedBox(
              height: _chipRowHeight.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categoryLabels.length,
                separatorBuilder: (_, __) => const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  final label = categoryLabels[index];
                  return CategoryWidget(
                    label: label,
                    icon: index == 0
                        ? Icons.apps_rounded
                        : categoryIconForName(label),
                    onTap: () => onCategoryTap(index),
                    selectedCategoryIndex: selectedCategoryIndex,
                    index: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeCategoriesHeaderDelegate oldDelegate) {
    return selectedCategoryIndex != oldDelegate.selectedCategoryIndex ||
        categoryLabels != oldDelegate.categoryLabels ||
        textTheme != oldDelegate.textTheme ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
