import 'package:goluto/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:goluto/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:goluto/src/features/home/presentation/utils/category_icons.dart';
import 'package:goluto/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:goluto/src/features/location/presentation/providers/location_provider.dart';
import 'package:goluto/src/features/home/presentation/widgets/category_widget.dart';
import 'package:goluto/src/features/home/presentation/widgets/home_header.dart';
import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/features/notifications/presentation/providers/notifications_provider.dart';
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
    final unreadCount = ref.watch(
      notificationsProvider.select((state) => state.unreadCount),
    );
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
          onRefresh: () async {
            await Future.wait([
              ref.read(homeFeedProvider.notifier).load(),
              ref.read(notificationsProvider.notifier).refreshUnreadCount(),
            ]);
          },
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
                  notificationUnreadCount: unreadCount,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.ms.w,
                    10.h,
                    AppSpacing.ms.w,
                    4.h,
                  ),
                  child: _HomeSearchBar(
                    onTap: () => context.push(AppRoutes.searchOffers),
                  ),
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
                    child: _EmptyCategoryState(
                      onClearFilter: homeFeedState.selectedCategoryIndex == 0
                          ? null
                          : () => ref
                              .read(homeFeedProvider.notifier)
                              .selectCategory(0),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.ms.w,
                        2.h,
                        AppSpacing.ms.w,
                        10.h,
                      ),
                      child: Text(
                        'Nearby stores',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.15,
                          color: colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
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
                          SizedBox(height: AppSpacing.ms.h),
                    ),
                  ),
                ],
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

class _EmptyCategoryState extends StatelessWidget {
  const _EmptyCategoryState({this.onClearFilter});

  final VoidCallback? onClearFilter;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 40,
            color: cs.onSurface.withValues(alpha: 0.35),
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            'No stores here yet',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            'Try another category or check back soon.',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
              height: 1.35,
            ),
          ),
          if (onClearFilter != null) ...[
            SizedBox(height: AppSpacing.lg.h),
            TextButton(
              onPressed: onClearFilter,
              child: const Text('Show all stores'),
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.lg,
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: AppBorders.lg,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Search brands or items',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.42),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  static const double _chipRowHeight = 36;
  static const double _verticalPad = 8;

  double get _pad => _verticalPad.h.ceilToDouble();
  double get _chipHeight => _chipRowHeight.h.ceilToDouble();

  double get _extent => (_pad + _chipHeight + _pad).ceilToDouble();

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
    return SizedBox(
      height: _extent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: overlapsContent
              ? Border(
                  bottom: BorderSide(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.ms.w,
            vertical: _pad,
          ),
          child: SizedBox(
            height: _chipHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categoryLabels.length,
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
