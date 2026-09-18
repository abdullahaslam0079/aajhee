import 'package:aajhee/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/home/presentation/utils/category_icons.dart';
import 'package:aajhee/src/features/home/presentation/widgets/category_widget.dart';
import 'package:aajhee/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:aajhee/src/features/home/presentation/widgets/home_header.dart';
import 'package:aajhee/src/features/location/presentation/providers/location_provider.dart';
import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

/// Stores tab: nearby branches with category filters.
class StoresTabScreen extends ConsumerWidget {
  const StoresTabScreen({super.key});

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
      backgroundColor: homeCanvasOf(context),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(homeFeedProvider.notifier).load(),
              ref.read(notificationsProvider.notifier).refreshUnreadCount(),
            ]);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 240) {
                ref.read(homeFeedProvider.notifier).loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedStoresHeaderDelegate(
                    locationText: locationText,
                    unreadCount: unreadCount,
                    backgroundColor: homeCanvasOf(context),
                    onLocationTap: () =>
                        showDeliveryAddressPicker(context, ref),
                    onFavoritesTap: () => context.push(AppRoutes.favorites),
                    onNotificationsTap: () =>
                        context.push(AppRoutes.notifications),
                  ),
                ),
                if (homeFeedState.isLoading && homeFeedState.branches.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppLoading(message: 'Loading stores...'),
                  )
                else if (homeFeedState.errorMessage != null &&
                    homeFeedState.branches.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _StoresFeedError(
                      message: homeFeedState.errorMessage!,
                      onRetry: () =>
                          ref.read(homeFeedProvider.notifier).load(),
                    ),
                  )
                else ...[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StoresCategoriesHeaderDelegate(
                      selectedCategoryIndex:
                          homeFeedState.selectedCategoryIndex,
                      categoryLabels: categoryLabels,
                      onCategoryTap: (index) => ref
                          .read(homeFeedProvider.notifier)
                          .selectCategory(index),
                      textTheme: textTheme,
                      backgroundColor: homeCanvasOf(context),
                    ),
                  ),
                  if (branches.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyCategoryState(
                        onClearFilter:
                            homeFeedState.selectedCategoryIndex == 0
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
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
                      sliver: SliverList.separated(
                        itemCount: branches.length +
                            (homeFeedState.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= branches.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.md.h,
                              ),
                              child: const AppLoading(size: 22, strokeWidth: 2.5),
                            );
                          }
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
      ),
    );
  }
}

class _PinnedStoresHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedStoresHeaderDelegate({
    required this.locationText,
    required this.unreadCount,
    required this.backgroundColor,
    required this.onLocationTap,
    required this.onFavoritesTap,
    required this.onNotificationsTap,
  });

  final String locationText;
  final int unreadCount;
  final Color backgroundColor;
  final VoidCallback onLocationTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onNotificationsTap;

  /// Padding + content; 44.h leaves room for location column + 40 icon buttons.
  double get _extent => (AppSpacing.xs.h * 2 + 44.h).ceilToDouble();

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
      child: SizedBox(
        height: _extent,
        child: HomeHeader(
          locationText: locationText,
          onLocationTap: onLocationTap,
          onFavoritesTap: onFavoritesTap,
          onNotificationsTap: onNotificationsTap,
          notificationUnreadCount: unreadCount,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedStoresHeaderDelegate oldDelegate) {
    return locationText != oldDelegate.locationText ||
        unreadCount != oldDelegate.unreadCount ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class _StoresFeedError extends StatelessWidget {
  const _StoresFeedError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.cloud_off_outlined,
      title: 'Could not load stores',
      message: message,
      onRetry: onRetry,
    );
  }
}

class _EmptyCategoryState extends StatelessWidget {
  const _EmptyCategoryState({this.onClearFilter});

  final VoidCallback? onClearFilter;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.storefront_outlined,
      title: 'No stores here yet',
      subtitle: 'Try another category or check back soon.',
      actionLabel: onClearFilter != null ? 'Show all stores' : null,
      onAction: onClearFilter,
    );
  }
}

class _StoresCategoriesHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StoresCategoriesHeaderDelegate({
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
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: _pad),
          child: SizedBox(
            height: _chipHeight,
            child: Stack(
              children: [
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
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
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: AppSpacing.ms.w + 12,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            backgroundColor.withValues(alpha: 0),
                            backgroundColor,
                          ],
                        ),
                      ),
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

  @override
  bool shouldRebuild(covariant _StoresCategoriesHeaderDelegate oldDelegate) {
    return selectedCategoryIndex != oldDelegate.selectedCategoryIndex ||
        categoryLabels != oldDelegate.categoryLabels ||
        textTheme != oldDelegate.textTheme ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
