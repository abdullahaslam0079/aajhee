import 'package:aajhee/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
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
                  4.h,
                  AppSpacing.ms.w,
                  8.h,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isMap ? 'Map' : 'Nearby shops',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.15,
                          color: colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    SegmentedButton<_ShopsViewMode>(
                      segments: const [
                        ButtonSegment(
                          value: _ShopsViewMode.list,
                          icon: Icon(Icons.view_list_rounded, size: 18),
                          label: Text('List'),
                        ),
                        ButtonSegment(
                          value: _ShopsViewMode.map,
                          icon: Icon(Icons.map_outlined, size: 18),
                          label: Text('Map'),
                        ),
                      ],
                      selected: {_viewMode},
                      onSelectionChanged: (selected) {
                        setState(() => _viewMode = selected.first);
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: WidgetStatePropertyAll(
                          textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      showSelectedIcon: false,
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
                                      SizedBox(height: AppSpacing.sm.h),
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
  });

  final String locationText;
  final int unreadCount;
  final int cartItemCount;
  final Color backgroundColor;
  final VoidCallback onLocationTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: HomeHeader(
        locationText: locationText,
        onLocationTap: onLocationTap,
        onFavoritesTap: onFavoritesTap,
        onNotificationsTap: onNotificationsTap,
        onCartTap: onCartTap,
        notificationUnreadCount: unreadCount,
        cartItemCount: cartItemCount,
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

  static const double _chipRowHeight = 36;
  static const double _verticalPad = 8;

  @override
  Widget build(BuildContext context) {
    final pad = _verticalPad.h.ceilToDouble();
    final chipHeight = _chipRowHeight.h.ceilToDouble();
    final rows = subcategories.isEmpty ? 1 : 2;
    final extent = (pad + (chipHeight * rows) + (rows > 1 ? 4.h : 0) + pad)
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
                height: chipHeight,
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
              if (subcategories.isNotEmpty) ...[
                SizedBox(height: 4.h),
                SizedBox(
                  height: chipHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
                    itemCount: subcategories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return CategoryWidget(
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
