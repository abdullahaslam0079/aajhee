part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _HomeCommerceScreenState extends ConsumerState<HomeCommerceScreen>
    with HomeCommerceScreenController {
  @override
  Widget build(BuildContext context) {
    ref.listen(savedAddressesProvider, (previous, next) {
      if (!next.selectedLocationChangedFrom(previous)) return;
      _load();
    });
    ref.listen(homeFeedProvider, (previous, next) {
      if (previous?.selectedCategoryId == next.selectedCategoryId) return;
      _syncProductsToCategory(next);
    });

    final addresses = ref.watch(savedAddressesProvider);
    final feed = ref.watch(homeFeedProvider);
    final unread = ref.watch(notificationsProvider).unreadCount;
    final cartCount = ref.watch(
      cartProvider.select((state) => state.totalQuantity),
    );
    final tt = Theme.of(context).textTheme;
    final canvas = homeCanvasOf(context);
    final bottomInset =
        kHomeFeedBottomInset + MediaQuery.paddingOf(context).bottom;

    final branches = feed.filteredBranches;
    final sameDayIds = _sameDayBusinessIds(branches);
    final locationText = _locationText(addresses.selectedAddress);
    final todayProducts = _productsForBusinessIds(sameDayIds);
    final visibleProducts = _applyListFilter(
      _products,
      sameDayBusinessIds: sameDayIds,
    );

    final categoryLabels = feed.categoryLabels;
    final showFeedSkeleton = _loading && _products.isEmpty;

    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedHomeHeaderDelegate(
                  locationText: locationText,
                  unreadCount: unread,
                  cartCount: cartCount,
                  backgroundColor: canvas,
                  onLocationTap: () => showDeliveryAddressPicker(context, ref),
                  onFavoritesTap: () => context.push(AppRoutes.favorites),
                  onNotificationsTap: () =>
                      context.push(AppRoutes.notifications),
                  onCartTap: () => context.push(AppRoutes.cart),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedSearchBarDelegate(
                  backgroundColor: canvas,
                  onTap: _openSearch,
                ),
              ),
              if (showFeedSkeleton)
                SliverToBoxAdapter(
                  child: _MarketplaceSkeleton(bottomInset: bottomInset),
                )
              else if (_error != null && _products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                    child: AppEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Could not load products',
                      subtitle: _error,
                      actionLabel: 'Retry',
                      onAction: _load,
                    ),
                  ),
                )
              else ...[
                if (categoryLabels.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: CategoryWidget.rowHeight,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.ms.w,
                              2.h,
                              AppSpacing.ms.w,
                              0,
                            ),
                            itemCount: categoryLabels.length,
                            itemBuilder: (context, index) {
                              final label = categoryLabels[index];
                              return CategoryWidget(
                                selectedCategoryIndex:
                                    feed.selectedCategoryIndex,
                                index: index,
                                label: label,
                                icon: index == 0
                                    ? Icons.grid_view_rounded
                                    : categoryIconForName(label),
                                onTap: () => ref
                                    .read(homeFeedProvider.notifier)
                                    .selectCategory(index),
                              );
                            },
                          ),
                        ),
                        if (feed.selectedSubcategories.isNotEmpty)
                          SizedBox(
                            height: CategoryWidget.compactRowHeight,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                AppSpacing.ms.w,
                                0,
                                AppSpacing.ms.w,
                                0,
                              ),
                              itemCount: feed.selectedSubcategories.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return CategoryWidget(
                                    compact: true,
                                    selectedCategoryIndex:
                                        feed.selectedSubcategoryId == null
                                            ? 0
                                            : -1,
                                    index: 0,
                                    label: 'All',
                                    icon: Icons.grid_view_rounded,
                                    onTap: () => ref
                                        .read(homeFeedProvider.notifier)
                                        .selectSubcategory(null),
                                  );
                                }
                                final sub =
                                    feed.selectedSubcategories[index - 1];
                                final selected =
                                    feed.selectedSubcategoryId == sub.id;
                                return CategoryWidget(
                                  compact: true,
                                  selectedCategoryIndex: selected ? index : -1,
                                  index: index,
                                  label: sub.name,
                                  icon: categoryIconForName(sub.name),
                                  onTap: () => ref
                                      .read(homeFeedProvider.notifier)
                                      .selectSubcategory(sub.id),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                if (todayProducts.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: _SectionTitle(
                      title: 'Get it today',
                      icon: Icons.bolt_rounded,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 168.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.ms.w,
                        ),
                        itemCount: todayProducts.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (context, index) {
                          final product = todayProducts[index];
                          return CommerceProductCard(
                            product: product,
                            width: 126.w,
                            onTap: () => _openProduct(product),
                            onAddTap: () => _addProductToCart(product),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                if (branches.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: _SectionTitle(
                      title: 'Shops near you',
                      icon: Icons.storefront_outlined,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) {
                        const imageHeight = 72.0;
                        const imageWidth = 58.0;
                        final pad = 8.w;
                        final cardHeight = imageHeight.w + (pad * 2);
                        return SizedBox(
                          height: cardHeight,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.ms.w,
                            ),
                            itemCount: branches.length,
                            separatorBuilder: (_, __) => SizedBox(width: 10.w),
                            itemBuilder: (context, index) {
                              final branch = branches[index];
                              return _NearbyShopCard(
                                branch: branch,
                                imageHeight: imageHeight,
                                imageWidth: imageWidth,
                                padding: pad,
                                onTap: () => _openBranch(branch),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedFiltersDelegate(
                    textTheme: tt,
                    backgroundColor: canvas,
                    listFilter: _listFilter,
                    onFilterSelected: (filter) {
                      if (_listFilter == filter) return;
                      setState(() => _listFilter = filter);
                    },
                  ),
                ),
                if (visibleProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                      child: AppEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: _listFilter == ProductListFilter.all
                            ? 'No products yet'
                            : 'No ${_listFilter.label.toLowerCase()} products',
                        subtitle: _listFilter == ProductListFilter.all
                            ? 'Check back soon for local picks.'
                            : 'Try another filter to see more products.',
                        actionLabel: _listFilter == ProductListFilter.all
                            ? null
                            : 'Show all',
                        onAction: _listFilter == ProductListFilter.all
                            ? null
                            : () => setState(
                                  () => _listFilter = ProductListFilter.all,
                                ),
                      ),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.ms.w,
                      0,
                      AppSpacing.ms.w,
                      _loadingMore ? AppSpacing.sm.h : bottomInset,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.h,
                        crossAxisSpacing: 10.w,
                        childAspectRatio: 0.78,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = visibleProducts[index];
                          return CommerceProductCard(
                            product: product,
                            onTap: () => _openProduct(product),
                            onAddTap: () => _addProductToCart(product),
                          );
                        },
                        childCount: visibleProducts.length,
                      ),
                    ),
                  ),
                  if (_loadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 4.h, 0, bottomInset),
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
