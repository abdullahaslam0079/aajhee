import 'package:aajhee/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/commerce_search_bar.dart';
import 'package:aajhee/src/features/home/data/models/category_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/home/presentation/utils/category_icons.dart';
import 'package:aajhee/src/features/home/presentation/widgets/category_widget.dart';
import 'package:aajhee/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:aajhee/src/features/home/presentation/widgets/home_header.dart';
import 'package:aajhee/src/features/location/presentation/providers/location_provider.dart';
import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/features/mapFeature/presentation/map_screen.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

enum _ShopsViewMode { list, map }

/// Shops tab: nearby branches with category filters and list/map toggle.
class StoresTabScreen extends ConsumerStatefulWidget {
  const StoresTabScreen({super.key});

  @override
  ConsumerState<StoresTabScreen> createState() => _StoresTabScreenState();
}

class _StoresTabScreenState extends ConsumerState<StoresTabScreen> {
  _ShopsViewMode _viewMode = _ShopsViewMode.list;

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProductSearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    final locationState = ref.watch(locationProvider);
    final savedAddressesState = ref.watch(savedAddressesProvider);
    final homeFeedState = ref.watch(homeFeedProvider);
    final unreadCount = ref.watch(
      notificationsProvider.select((state) => state.unreadCount),
    );
    final cartItemCount = ref.watch(
      cartProvider.select((state) => state.totalQuantity),
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
    final isMap = _viewMode == _ShopsViewMode.map;

    return Scaffold(
      backgroundColor: homeCanvasOf(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _PinnedStoresHeader(
              locationText: locationText,
              unreadCount: unreadCount,
              cartItemCount: cartItemCount,
              backgroundColor: homeCanvasOf(context),
              onLocationTap: () => showDeliveryAddressPicker(context, ref),
              onFavoritesTap: () => context.push(AppRoutes.favorites),
              onNotificationsTap: () => context.push(AppRoutes.notifications),
              onCartTap: () => context.push(AppRoutes.cart),
              onSearchTap: _openSearch,
            ),
            if (homeFeedState.isLoading && homeFeedState.branches.isEmpty)
              const Expanded(
                child: AppLoading(message: 'Loading shops...'),
              )
            else if (homeFeedState.errorMessage != null &&
                homeFeedState.branches.isEmpty)
              Expanded(
                child: _StoresFeedError(
                  message: homeFeedState.errorMessage!,
                  onRetry: () => ref.read(homeFeedProvider.notifier).load(),
                ),
              )
            else ...[
              _StoresCategoriesHeader(
                selectedCategoryIndex: homeFeedState.selectedCategoryIndex,
                categoryLabels: categoryLabels,
                subcategories: homeFeedState.selectedSubcategories,
                selectedSubcategoryId: homeFeedState.selectedSubcategoryId,
                onCategoryTap: (index) =>
                    ref.read(homeFeedProvider.notifier).selectCategory(index),
                onSubcategoryTap: (id) =>
                    ref.read(homeFeedProvider.notifier).selectSubcategory(id),
                textTheme: textTheme,
                backgroundColor: homeCanvasOf(context),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.ms.w,
                  8.h,
                  AppSpacing.ms.w,
                  10.h,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMap ? 'Map' : 'Nearby shops',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (!isMap) ...[
                            SizedBox(height: 2.h),
                            Text(
                              'Discover great stores near you',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _ListMapToggle(
                      mode: _viewMode,
                      onChanged: (mode) => setState(() => _viewMode = mode),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isMap
                    ? const MapScreen()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await Future.wait([
                            ref.read(homeFeedProvider.notifier).load(),
                            ref
                                .read(notificationsProvider.notifier)
                                .refreshUnreadCount(),
                          ]);
                        },
                        child: branches.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                children: [
                                  SizedBox(height: 80.h),
                                  _EmptyCategoryState(
                                    onClearFilter:
                                        homeFeedState.selectedCategoryIndex == 0
                                            ? null
                                            : () => ref
                                                .read(homeFeedProvider.notifier)
                                                .selectCategory(0),
                                  ),
                                ],
                              )
                            : NotificationListener<ScrollNotification>(
                                onNotification: (notification) {
                                  if (notification.metrics.pixels >=
                                      notification.metrics.maxScrollExtent -
                                          240) {
                                    ref
                                        .read(homeFeedProvider.notifier)
                                        .loadMore();
                                  }
                                  return false;
                                },
                                child: ListView.separated(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: EdgeInsets.fromLTRB(
                                    AppSpacing.ms.w,
                                    0,
                                    AppSpacing.ms.w,
                                    bottomInset,
                                  ),
                                  itemCount: branches.length +
                                      (homeFeedState.isLoadingMore ? 1 : 0),
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: 14.h),
                                  itemBuilder: (context, index) {
                                    if (index >= branches.length) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: AppSpacing.md.h,
                                        ),
                                        child: const AppLoading(
                                          size: 22,
                                          strokeWidth: 2.5,
                                        ),
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
                                ),
                              ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListMapToggle extends StatelessWidget {
  const _ListMapToggle({
    required this.mode,
    required this.onChanged,
  });

  final _ShopsViewMode mode;
  final ValueChanged<_ShopsViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppBorders.full,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            selected: mode == _ShopsViewMode.list,
            icon: Icons.view_list_rounded,
            label: 'List',
            onTap: () => onChanged(_ShopsViewMode.list),
            textTheme: tt,
            colorScheme: cs,
          ),
          _ToggleChip(
            selected: mode == _ShopsViewMode.map,
            icon: Icons.map_outlined,
            label: 'Map',
            onTap: () => onChanged(_ShopsViewMode.map),
            textTheme: tt,
            colorScheme: cs,
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.textTheme,
    required this.colorScheme,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.85)
          : Colors.transparent,
      borderRadius: AppBorders.full,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.full,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedStoresHeader extends StatelessWidget {
  const _PinnedStoresHeader({
    required this.locationText,
    required this.unreadCount,
    required this.cartItemCount,
    required this.backgroundColor,
    required this.onLocationTap,
    required this.onFavoritesTap,
    required this.onNotificationsTap,
    required this.onCartTap,
    required this.onSearchTap,
  });

  final String locationText;
  final int unreadCount;
  final int cartItemCount;
  final Color backgroundColor;
  final VoidCallback onLocationTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onCartTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Column(
        children: [
          HomeHeader(
            locationText: locationText,
            onLocationTap: onLocationTap,
            onFavoritesTap: onFavoritesTap,
            onNotificationsTap: onNotificationsTap,
            onCartTap: onCartTap,
            notificationUnreadCount: unreadCount,
            cartItemCount: cartItemCount,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.ms.w,
              6.h,
              AppSpacing.ms.w,
              8.h,
            ),
            child: CommerceSearchBar(
              onTap: onSearchTap,
              hintText: 'Search for products, brands and more...',
            ),
          ),
        ],
      ),
    );
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
      title: 'Could not load shops',
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
      title: 'No shops here yet',
      subtitle: 'Try another category or check back soon.',
      actionLabel: onClearFilter != null ? 'Show all shops' : null,
      onAction: onClearFilter,
    );
  }
}

class _StoresCategoriesHeader extends StatelessWidget {
  const _StoresCategoriesHeader({
    required this.selectedCategoryIndex,
    required this.categoryLabels,
    required this.subcategories,
    required this.selectedSubcategoryId,
    required this.onCategoryTap,
    required this.onSubcategoryTap,
    required this.textTheme,
    required this.backgroundColor,
  });

  final int selectedCategoryIndex;
  final List<String> categoryLabels;
  final List<CategoryModel> subcategories;
  final int? selectedSubcategoryId;
  final ValueChanged<int> onCategoryTap;
  final ValueChanged<int?> onSubcategoryTap;
  final TextTheme textTheme;
  final Color backgroundColor;

  static const double _verticalPad = 4;

  @override
  Widget build(BuildContext context) {
    final pad = _verticalPad.h.ceilToDouble();
    final mainHeight = CategoryWidget.rowHeight.ceilToDouble();
    final subHeight = CategoryWidget.compactRowHeight.ceilToDouble();
    final rows = subcategories.isEmpty ? 1 : 2;
    final extent = (pad +
            mainHeight +
            (rows > 1 ? 4.h + subHeight : 0) +
            pad)
        .ceilToDouble();

    return SizedBox(
      height: extent,
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: pad),
          child: Column(
            children: [
              SizedBox(
                height: mainHeight,
                child: Stack(
                  children: [
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
                      itemCount: categoryLabels.length,
                      itemBuilder: (context, index) {
                        final label = categoryLabels[index];
                        return CategoryWidget(
                          label: label,
                          icon: index == 0
                              ? Icons.grid_view_rounded
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
              if (subcategories.isNotEmpty) ...[
                SizedBox(height: 4.h),
                SizedBox(
                  height: subHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
                    itemCount: subcategories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return CategoryWidget(
                          compact: true,
                          label: 'All',
                          icon: Icons.grid_view_rounded,
                          onTap: () => onSubcategoryTap(null),
                          selectedCategoryIndex:
                              selectedSubcategoryId == null ? 0 : -1,
                          index: 0,
                        );
                      }
                      final sub = subcategories[index - 1];
                      final selected = selectedSubcategoryId == sub.id;
                      return CategoryWidget(
                        compact: true,
                        label: sub.name,
                        icon: categoryIconForName(sub.name),
                        onTap: () => onSubcategoryTap(sub.id),
                        selectedCategoryIndex: selected ? index : -1,
                        index: index,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
