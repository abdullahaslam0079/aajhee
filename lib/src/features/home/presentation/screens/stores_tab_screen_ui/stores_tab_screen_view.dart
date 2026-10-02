part of 'package:aajhee/src/features/home/presentation/screens/stores_tab_screen.dart';

class _StoresTabScreenState extends ConsumerState<StoresTabScreen>
    with StoresTabScreenController {
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
                  4.h,
                  AppSpacing.ms.w,
                  8.h,
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
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (!isMap) ...[
                            SizedBox(height: 1.h),
                            Text(
                              'Discover great stores near you',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.45),
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
                                      SizedBox(height: 10.h),
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
