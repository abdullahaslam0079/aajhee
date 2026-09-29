import 'dart:async';

import 'package:aajhee/src/config/launch_cities.dart';
import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/commerce/domain/commerce_labels.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/commerce_search_bar.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/home/presentation/utils/category_icons.dart';
import 'package:aajhee/src/features/home/presentation/widgets/category_widget.dart';
import 'package:aajhee/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:aajhee/src/features/home/presentation/widgets/home_header.dart';
import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:aajhee/src/features/settings/domain/entities/saved_address.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/shared/widgets/store_logo_badge.dart';
import 'package:aajhee/src/utils/money_format.dart';

class HomeCommerceScreen extends ConsumerStatefulWidget {
  const HomeCommerceScreen({super.key});

  @override
  ConsumerState<HomeCommerceScreen> createState() => _HomeCommerceScreenState();
}

class _HomeCommerceScreenState extends ConsumerState<HomeCommerceScreen> {
  final _api = CommerceApiService(DioService.instance);
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _products = const [];
  ProductListFilter _listFilter = ProductListFilter.all;
  String? _error;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      _ensureHomeFeedLoaded();
      _load();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _ensureHomeFeedLoaded() {
    final feed = ref.read(homeFeedProvider);
    if (feed.categories.isEmpty && !feed.isLoading) {
      unawaited(ref.read(homeFeedProvider.notifier).load());
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _loadingMore || !_hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _loadMoreProducts();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    _ensureHomeFeedLoaded();
    final productsResult = await _api.listProducts(page: 1, pageSize: 20);
    unawaited(ref.read(cartProvider.notifier).refresh());
    if (!mounted) return;

    String? error;
    var products = <Map<String, dynamic>>[];
    var hasMore = false;

    productsResult.fold(
      (f) => error = f.message,
      (data) {
        products = _asProductList(data['results']);
        hasMore = data['next'] != null;
      },
    );

    setState(() {
      _products = products;
      _hasMore = hasMore;
      _page = 1;
      _loading = false;
      _error = products.isEmpty ? error : null;
    });
  }

  Future<void> _loadMoreProducts() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final nextPage = _page + 1;
    final result = await _api.listProducts(page: nextPage, pageSize: 20);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loadingMore = false),
      (data) {
        final more = _asProductList(data['results']);
        setState(() {
          _products = _dedupeById([..._products, ...more]);
          _page = nextPage;
          _hasMore = data['next'] != null;
          _loadingMore = false;
        });
      },
    );
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(homeFeedProvider.notifier).load(),
      _load(),
    ]);
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  static List<Map<String, dynamic>> _asProductList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static List<Map<String, dynamic>> _dedupeById(
    List<Map<String, dynamic>> items,
  ) {
    final seen = <Object?>{};
    final out = <Map<String, dynamic>>[];
    for (final item in items) {
      final id = item['id'];
      if (id != null && !seen.add(id)) continue;
      out.add(item);
    }
    return out;
  }

  static Set<int> _sameDayBusinessIds(List<MapBranchModel> branches) {
    return {
      for (final branch in branches)
        if (branch.treatsAsSameDay && branch.businessId > 0) branch.businessId,
    };
  }

  static Set<int> _businessIds(List<MapBranchModel> branches) {
    return {
      for (final branch in branches)
        if (branch.businessId > 0) branch.businessId,
    };
  }

  List<Map<String, dynamic>> _productsForBusinessIds(Set<int> businessIds) {
    if (businessIds.isEmpty) return const [];
    return _products.where((product) {
      final id = _asInt(product['business_id']);
      return id != null && businessIds.contains(id);
    }).toList();
  }

  List<Map<String, dynamic>> _categoryScopedProducts({
    required int selectedCategoryIndex,
    required Set<int> categoryBusinessIds,
  }) {
    if (selectedCategoryIndex <= 0) return _products;
    if (categoryBusinessIds.isEmpty) return const [];
    return _productsForBusinessIds(categoryBusinessIds);
  }

  List<Map<String, dynamic>> _applyListFilter(
    List<Map<String, dynamic>> products, {
    required Set<int> sameDayBusinessIds,
  }) {
    switch (_listFilter) {
      case ProductListFilter.all:
        return products;
      case ProductListFilter.sameDay:
        if (sameDayBusinessIds.isEmpty) return const [];
        return products.where((product) {
          final id = _asInt(product['business_id']);
          return id != null && sameDayBusinessIds.contains(id);
        }).toList();
      case ProductListFilter.topRated:
        final sorted = [...products];
        sorted.sort((a, b) {
          final aRating = _asDouble(a['rating_avg']);
          final bRating = _asDouble(b['rating_avg']);
          if (aRating == null && bRating == null) return 0;
          if (aRating == null) return 1;
          if (bRating == null) return -1;
          return bRating.compareTo(aRating);
        });
        return sorted;
      case ProductListFilter.priceLowToHigh:
        final sorted = [...products];
        sorted.sort((a, b) {
          final aPrice =
              _asDouble(a['effective_price'] ?? a['base_price']) ??
                  double.infinity;
          final bPrice =
              _asDouble(b['effective_price'] ?? b['base_price']) ??
                  double.infinity;
          return aPrice.compareTo(bPrice);
        });
        return sorted;
    }
  }

  String _locationText(SavedAddress? address) {
    if (address == null) return 'Add address';
    final city = address.city.trim();
    final area = address.landmark.trim().isNotEmpty
        ? address.landmark.trim()
        : address.street.trim();
    if (city.isNotEmpty && area.isNotEmpty && area.length <= 28) {
      return '$area, $city';
    }
    if (city.isNotEmpty) return city;
    if (area.isNotEmpty) return area;
    final short = address.shortLabel.trim();
    if (short.isNotEmpty) return short;
    return 'Add address';
  }

  String _cityForBanner(SavedAddress? address) {
    final city = address?.city.trim() ?? '';
    if (city.isNotEmpty) return city;
    return primaryCityName;
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProductSearchScreen(),
      ),
    );
  }

  void _openProduct(Map<String, dynamic> product) {
    context.push(
      AppRoutes.productDetail('${product['id']}'),
      extra: product,
    );
  }

  void _openBranch(MapBranchModel branch) {
    context.push(AppRoutes.businessStore, extra: branch);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(savedAddressesProvider, (previous, next) {
      if (!next.selectedLocationChangedFrom(previous)) return;
      _load();
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
    final categoryBusinessIds = _businessIds(branches);
    final hasSameDayShops = sameDayIds.isNotEmpty;
    final cityLabel = _cityForBanner(addresses.selectedAddress);
    final locationText = _locationText(addresses.selectedAddress);

    final todayProducts = _productsForBusinessIds(sameDayIds);
    final scopedProducts = _categoryScopedProducts(
      selectedCategoryIndex: feed.selectedCategoryIndex,
      categoryBusinessIds: categoryBusinessIds,
    );
    final visibleProducts = _applyListFilter(
      scopedProducts,
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
                  onLocationTap: () =>
                      showDeliveryAddressPicker(context, ref),
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
                    child: SizedBox(
                      height: 40.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.ms.w,
                          4.h,
                          AppSpacing.ms.w,
                          4.h,
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
                                ? Icons.apps_rounded
                                : categoryIconForName(label),
                            onTap: () => ref
                                .read(homeFeedProvider.notifier)
                                .selectCategory(index),
                          );
                        },
                      ),
                    ),
                  ),
                if (hasSameDayShops)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.ms.w,
                        AppSpacing.sm.h,
                        AppSpacing.ms.w,
                        AppSpacing.xs.h,
                      ),
                      child: _SameDayBanner(
                        label: labelSameDayDelivery(cityLabel),
                      ),
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
                          return _TodayProductCard(
                            product: product,
                            onTap: () => _openProduct(product),
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
                    child: SizedBox(
                      height: 132.h,
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
                            onTap: () => _openBranch(branch),
                          );
                        },
                      ),
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
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = visibleProducts[index];
                          return _ProductGridCard(
                            product: product,
                            onTap: () => _openProduct(product),
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

class _PinnedHomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHomeHeaderDelegate({
    required this.locationText,
    required this.unreadCount,
    required this.cartCount,
    required this.backgroundColor,
    required this.onLocationTap,
    required this.onFavoritesTap,
    required this.onNotificationsTap,
    required this.onCartTap,
  });

  final String locationText;
  final int unreadCount;
  final int cartCount;
  final Color backgroundColor;
  final VoidCallback onLocationTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onCartTap;

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
          onCartTap: onCartTap,
          notificationUnreadCount: unreadCount,
          cartItemCount: cartCount,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHomeHeaderDelegate oldDelegate) {
    return locationText != oldDelegate.locationText ||
        unreadCount != oldDelegate.unreadCount ||
        cartCount != oldDelegate.cartCount ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class _PinnedSearchBarDelegate extends SliverPersistentHeaderDelegate {
  _PinnedSearchBarDelegate({
    required this.backgroundColor,
    required this.onTap,
  });

  final Color backgroundColor;
  final VoidCallback onTap;

  double get _topPad => 4.h.ceilToDouble();
  double get _bottomPad => 4.h.ceilToDouble();
  double get _barHeight => (13.h * 2 + 20).ceilToDouble();
  double get _extent => (_topPad + _barHeight + _bottomPad).ceilToDouble();

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
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.ms.w,
            _topPad,
            AppSpacing.ms.w,
            _bottomPad,
          ),
          child: CommerceSearchBar(
            onTap: onTap,
            hintText: 'Search shops & products',
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchBarDelegate oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor;
  }
}

class _PinnedFiltersDelegate extends SliverPersistentHeaderDelegate {
  _PinnedFiltersDelegate({
    required this.textTheme,
    required this.backgroundColor,
    required this.listFilter,
    required this.onFilterSelected,
  });

  final TextTheme textTheme;
  final Color backgroundColor;
  final ProductListFilter listFilter;
  final ValueChanged<ProductListFilter> onFilterSelected;

  double get _topPad => AppSpacing.sm.h.ceilToDouble();
  double get _titleGap => AppSpacing.xs.h.ceilToDouble();
  double get _bottomPad => AppSpacing.xs.h.ceilToDouble();
  double get _titleHeight => 20.h.ceilToDouble();
  double get _chipsHeight => 34.h.ceilToDouble();
  double get _shadowPad => 8;

  double get _contentExtent =>
      (_topPad + _titleHeight + _titleGap + _chipsHeight + _bottomPad)
          .ceilToDouble();

  double get _extent => (_contentExtent + _shadowPad).ceilToDouble();

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.08);

    return SizedBox(
      height: _extent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: backgroundColor,
            child: SizedBox(
              height: _contentExtent,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.ms.w,
                  _topPad,
                  AppSpacing.ms.w,
                  _bottomPad,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: _titleHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'All products',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: _titleGap),
                    SizedBox(
                      height: _chipsHeight,
                      child: _ProductListFilterChips(
                        selected: listFilter,
                        onSelected: onFilterSelected,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: _shadowPad,
            child: overlapsContent
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          shadowColor,
                          shadowColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  )
                : ColoredBox(color: backgroundColor),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedFiltersDelegate oldDelegate) {
    return listFilter != oldDelegate.listFilter ||
        textTheme != oldDelegate.textTheme ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class _ProductListFilterChips extends StatelessWidget {
  const _ProductListFilterChips({
    required this.selected,
    required this.onSelected,
  });

  final ProductListFilter selected;
  final ValueChanged<ProductListFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: ProductListFilter.values.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = ProductListFilter.values[index];
          final isSelected = filter == selected;
          final cs = context.theme.colorScheme;
          final tt = context.theme.textTheme;
          final isDark = cs.brightness == Brightness.dark;
          final bg = isSelected
              ? cs.primary
              : isDark
                  ? cs.surfaceContainerHigh
                  : cs.surfaceContainerLowest;
          final fg = isSelected ? cs.onPrimary : cs.onSurfaceVariant;
          final icon = switch (filter) {
            ProductListFilter.all => Icons.grid_view_rounded,
            ProductListFilter.sameDay => Icons.bolt_rounded,
            ProductListFilter.topRated => Icons.star_outline_rounded,
            ProductListFilter.priceLowToHigh => Icons.south_rounded,
          };

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(filter),
              borderRadius: AppBorders.md,
              child: Ink(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: AppBorders.md,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark
                              ? cs.outline.withValues(alpha: 0.32)
                              : cs.outlineVariant,
                        ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14.sp, color: fg),
                      SizedBox(width: 5.w),
                      Text(
                        filter.label,
                        style: tt.labelMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: fg,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.ms.w,
        AppSpacing.sm.h,
        AppSpacing.ms.w,
        AppSpacing.xs.h,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.primary),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              title,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SameDayBanner extends StatelessWidget {
  const _SameDayBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: AppBorders.md,
        border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, size: 20, color: cs.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: tt.labelLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayProductCard extends StatelessWidget {
  const _TodayProductCard({
    required this.product,
    required this.onTap,
  });

  final Map<String, dynamic> product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final discount = _discountLabel(product);
    final imageUrl = product['image_url']?.toString();
    final businessName = product['business_name']?.toString() ?? '';
    final price = formatRs(product['effective_price'] ?? product['base_price']);
    final basePrice = formatRsOrNull(product['base_price']);
    final showStrike = discount != null &&
        basePrice != null &&
        basePrice != price;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.md,
        child: Ink(
          width: 124.w,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppBorders.md,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: _ProductThumb(imageUrl: imageUrl),
                    ),
                    Positioned(
                      top: 6.h,
                      left: 6.w,
                      child: const _TodayBadge(),
                    ),
                    if (discount != null)
                      Positioned(
                        left: 6.w,
                        bottom: 6.h,
                        child: _DiscountBadge(label: discount),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (businessName.isNotEmpty)
                      Text(
                        businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    SizedBox(height: 2.h),
                    Text(
                      product['name']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    _PriceRow(
                      price: price,
                      basePrice: showStrike ? basePrice : null,
                      emphasize: discount != null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyShopCard extends StatelessWidget {
  const _NearbyShopCard({
    required this.branch,
    required this.onTap,
  });

  final MapBranchModel branch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final badge = branch.deliveryBadgeLabel;
    final distance = branch.distanceKm;
    final fee = branch.deliveryFee;
    final rating = branch.ratingAvg;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.md,
        child: Ink(
          width: 168.w,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppBorders.md,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StoreLogoBadge(
                    name: branch.displayName,
                    imageUrl: branch.logoUrl,
                    size: 36,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        if (branch.categoryName.trim().isNotEmpty)
                          Text(
                            branch.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.15,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (rating != null && rating > 0)
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: context.appColors.deal,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      rating.toStringAsFixed(1),
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 4.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (badge != null)
                    _MetaChip(
                      label: badge,
                      emphasized: badge == 'Same-day',
                    ),
                  if (distance != null)
                    Text(
                      '${distance.toStringAsFixed(1)} km',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.1,
                      ),
                    ),
                  if (fee != null)
                    Text(
                      formatRs(fee),
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.1,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    this.emphasized = false,
  });

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = emphasized
        ? cs.primary.withValues(alpha: 0.12)
        : cs.surfaceContainerHighest;
    final fg = emphasized ? cs.primary : cs.onSurfaceVariant;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppBorders.full,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              height: 1.1,
            ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({
    required this.product,
    required this.onTap,
  });

  final Map<String, dynamic> product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final discount = _discountLabel(product);
    final imageUrl = product['image_url']?.toString();
    final businessName = product['business_name']?.toString() ?? '';
    final price = formatRs(product['effective_price'] ?? product['base_price']);
    final basePrice = formatRsOrNull(product['base_price']);
    final showStrike = discount != null &&
        basePrice != null &&
        basePrice != price;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.md,
        child: Ink(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppBorders.md,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: _ProductThumb(imageUrl: imageUrl),
                    ),
                    if (discount != null)
                      Positioned(
                        left: 6.w,
                        bottom: 6.h,
                        child: _DiscountBadge(label: discount),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 7.h, 8.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (businessName.isNotEmpty)
                      Text(
                        businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    SizedBox(height: 3.h),
                    Text(
                      product['name']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _PriceRow(
                      price: price,
                      basePrice: showStrike ? basePrice : null,
                      emphasize: discount != null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ColoredBox(
          color: cs.surfaceContainerHighest,
          child: Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
        ),
      );
    }
    return ColoredBox(
      color: cs.surfaceContainerHighest,
      child: Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.price,
    required this.emphasize,
    this.basePrice,
  });

  final String price;
  final String? basePrice;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelLarge?.copyWith(
              color: emphasize ? context.appColors.deal : cs.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ),
        if (basePrice != null && basePrice!.isNotEmpty) ...[
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              basePrice!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                decoration: TextDecoration.lineThrough,
                height: 1.1,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TodayBadge extends StatelessWidget {
  const _TodayBadge();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: AppBorders.full,
      ),
      child: Text(
        'Today',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w800,
              height: 1.1,
              fontSize: 9,
            ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: appColors.deal,
        borderRadius: AppBorders.full,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: appColors.onDeal,
              fontWeight: FontWeight.w800,
              height: 1.1,
              fontSize: 9,
            ),
      ),
    );
  }
}

class _MarketplaceSkeleton extends StatelessWidget {
  const _MarketplaceSkeleton({required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bone = cs.surfaceContainerHighest;

    Widget box({
      required double height,
      double? width,
      BorderRadius? radius,
    }) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: bone,
          borderRadius: radius ?? AppBorders.md,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.ms.w,
        AppSpacing.sm.h,
        AppSpacing.ms.w,
        bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 34.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, __) => box(height: 34.h, width: 78.w),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          box(height: 48.h),
          SizedBox(height: AppSpacing.md.h),
          box(height: 16.h, width: 120.w),
          SizedBox(height: AppSpacing.xs.h),
          SizedBox(
            height: 150.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, __) => box(height: 150.h, width: 120.w),
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          box(height: 16.h, width: 140.w),
          SizedBox(height: AppSpacing.xs.h),
          SizedBox(
            height: 120.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, __) => box(height: 120.h, width: 160.w),
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          box(height: 16.h, width: 110.w),
          SizedBox(height: AppSpacing.xs.h),
          Row(
            children: [
              Expanded(child: box(height: 180.h)),
              SizedBox(width: 10.w),
              Expanded(child: box(height: 180.h)),
            ],
          ),
        ],
      ),
    );
  }
}

String? _discountLabel(Map<String, dynamic> product) {
  if (product['has_discount'] != true) return null;
  final raw = product['effective_discount_percent'];
  final parsed = raw is num ? raw.toDouble() : double.tryParse('$raw');
  if (parsed == null || parsed <= 0) return null;
  final label = parsed == parsed.roundToDouble()
      ? '${parsed.toInt()}%'
      : '${parsed.toStringAsFixed(0)}%';
  return '$label off';
}
