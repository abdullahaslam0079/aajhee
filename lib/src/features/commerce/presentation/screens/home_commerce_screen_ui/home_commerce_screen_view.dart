part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _HomeCommerceScreenState extends ConsumerState<HomeCommerceScreen>
    with HomeCommerceScreenController {
  @override
  Widget build(BuildContext context) {
    // Reload home when the selected delivery location changes.
    ref.listen(savedAddressesProvider, (previous, next) {
      if (!next.selectedLocationChangedFrom(previous)) return;
      _load();
    });

    // Watched providers used by header badges and feed sections.
    final addresses = ref.watch(savedAddressesProvider);
    final feed = ref.watch(homeFeedProvider);
    final unread = ref.watch(notificationsProvider).unreadCount;
    final cartCount = ref.watch(
      cartProvider.select((state) => state.totalQuantity),
    );
    final canvas = homeCanvasOf(context);
    final bottomInset =
        kHomeFeedBottomInset + MediaQuery.paddingOf(context).bottom;

    // Derived feed slices for each carousel / shop section.
    final sameDayIds = _sameDayBusinessIds(_nearbyBranches);
    final locationText = _locationText(addresses.selectedAddress);
    final todayProducts = _todayProducts(sameDayIds);
    final nearbyShops =
        _nearbyBranches.take(_kCarouselShopLimit).toList(growable: false);
    final exploreShops = _exploreBranches(feed.categories);
    final popularProducts = _popularProducts(
      excludeIds: _productIds(todayProducts),
    );
    final browseProducts = _browseProducts(
      excludeIds: {
        ..._productIds(todayProducts),
        ..._productIds(popularProducts),
      },
    );
    final categoryLabels = feed.categoryLabels;
    // Show skeleton only on the initial empty load.
    final showFeedSkeleton = _loading &&
        _products.isEmpty &&
        _nearbyBranches.isEmpty &&
        _homeFeeds.trending.isEmpty;

    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Pinned location + actions header.
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
              // Pinned search entry point.
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedSearchBarDelegate(
                  backgroundColor: canvas,
                  onTap: _openSearch,
                ),
              ),
              // Initial loading placeholder.
              if (showFeedSkeleton)
                SliverToBoxAdapter(
                  child: _MarketplaceSkeleton(bottomInset: bottomInset),
                )
              // Full-screen error when nothing loaded.
              else if (_error != null &&
                  _products.isEmpty &&
                  _nearbyBranches.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                    child: AppEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Could not load home',
                      subtitle: _error,
                      actionLabel: 'Retry',
                      onAction: _load,
                    ),
                  ),
                )
              else ...[
                // Same-day delivery products.
                if (todayProducts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionTitle(
                      title: 'Get it today',
                      subtitle: 'Fresh picks, delivered same-day',
                      icon: Icons.bolt_rounded,
                      onSeeAll: _openSearch,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _ProductCarousel(
                      products: todayProducts,
                      onProductTap: _openProduct,
                      onAddTap: _addProductToCart,
                    ),
                  ),
                ],
                // Nearby shops carousel.
                if (nearbyShops.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionTitle(
                      title: 'Shops near you',
                      subtitle: 'Trusted local shops around your area',
                      icon: Icons.storefront_outlined,
                      onSeeAll: () => _openShopsTab(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _ShopCarousel(
                      branches: nearbyShops,
                      onBranchTap: _openBranch,
                    ),
                  ),
                ],
                // Category chips + filtered local shops.
                if (categoryLabels.isNotEmpty || exploreShops.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionTitle(
                      title: 'Explore local shops',
                      subtitle: 'Browse by category and find what you need',
                      icon: Icons.explore_outlined,
                      onSeeAll: () =>
                          _openShopsTab(categoryIndex: _exploreCategoryIndex),
                    ),
                  ),
                  if (categoryLabels.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _ExploreCategoryChips(
                          labels: categoryLabels,
                          selectedIndex: _exploreCategoryIndex,
                          onSelected: _onExploreCategorySelected,
                        ),
                      ),
                    ),
                  if (exploreShops.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ShopCarousel(
                        branches: exploreShops,
                        onBranchTap: _openBranch,
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.ms.w,
                          0,
                          AppSpacing.ms.w,
                          AppSpacing.xs.h,
                        ),
                        child: Text(
                          'No shops in this category nearby yet.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ),
                ],
                // Trending products, excluding same-day items.
                if (popularProducts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionTitle(
                      title: 'Popular around you',
                      subtitle: 'Trending products from nearby shops',
                      icon: Icons.local_fire_department_outlined,
                      onSeeAll: _openSearch,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _ProductCarousel(
                      products: popularProducts,
                      onProductTap: _openProduct,
                      onAddTap: _addProductToCart,
                    ),
                  ),
                ],
                // Remaining products for browsing; keeps bottom inset.
                if (browseProducts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionTitle(
                      title: 'More to browse',
                      subtitle: 'Keep exploring local picks',
                      icon: Icons.shopping_bag_outlined,
                      onSeeAll: _openSearch,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomInset),
                      child: _ProductCarousel(
                        products: browseProducts,
                        onProductTap: _openProduct,
                        onAddTap: _addProductToCart,
                      ),
                    ),
                  ),
                ] else
                  // Spacer so last section clears the bottom nav.
                  SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
