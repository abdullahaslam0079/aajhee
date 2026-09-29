import 'dart:async';

import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/commerce/domain/commerce_labels.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';
import 'package:aajhee/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:aajhee/src/features/home/presentation/widgets/home_header.dart';
import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/commerce_search_bar.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class HomeCommerceScreen extends ConsumerStatefulWidget {
  const HomeCommerceScreen({super.key});

  @override
  ConsumerState<HomeCommerceScreen> createState() => _HomeCommerceScreenState();
}

class _HomeCommerceScreenState extends ConsumerState<HomeCommerceScreen> {
  final _api = CommerceApiService(DioService.instance);
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _topPicks = const [];
  List<Map<String, dynamic>> _products = const [];
  final Map<int, ({bool showInStore, bool showOnline})> _businessChannels = {};

  ProductChannelFilter _channelFilter = ProductChannelFilter.all;
  String? _error;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
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

    final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
    final feedsResult = await _api.getHomeFeeds(addressId: addressId);
    final productsResult = await _api.listProducts(page: 1, pageSize: 20);
    unawaited(ref.read(cartProvider.notifier).refresh());
    if (!mounted) return;

    String? error;
    var topPicks = <Map<String, dynamic>>[];
    var products = <Map<String, dynamic>>[];
    var hasMore = false;

    feedsResult.fold(
      (f) => error = f.message,
      (data) {
        topPicks = _asProductList(data['top_picks']);
      },
    );

    productsResult.fold(
      (f) => error ??= f.message,
      (data) {
        products = _asProductList(data['results']);
        hasMore = data['next'] != null;
      },
    );

    // Fallback when /api/products is empty: use home-feed product shelves.
    if (products.isEmpty) {
      feedsResult.fold((_) {}, (data) {
        products = _dedupeById([
          ..._asProductList(data['top_picks']),
          ..._asProductList(data['offers']),
          ..._asProductList(data['trending']),
        ]);
        hasMore = false;
      });
    }

    setState(() {
      _topPicks = topPicks;
      _products = products;
      _hasMore = hasMore;
      _page = 1;
      _loading = false;
      _error = products.isEmpty && topPicks.isEmpty ? error : null;
    });

    await _ensureBusinessChannels([...topPicks, ...products]);
  }

  Future<void> _loadMoreProducts() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final nextPage = _page + 1;
    final result = await _api.listProducts(page: nextPage, pageSize: 20);
    if (!mounted) return;
    await result.fold(
      (_) async => setState(() => _loadingMore = false),
      (data) async {
        final more = _asProductList(data['results']);
        setState(() {
          _products = _dedupeById([..._products, ...more]);
          _page = nextPage;
          _hasMore = data['next'] != null;
          _loadingMore = false;
        });
        await _ensureBusinessChannels(more);
      },
    );
  }

  Future<void> _ensureBusinessChannels(
    List<Map<String, dynamic>> products,
  ) async {
    final ids = <int>{};
    for (final product in products) {
      final id = _asInt(product['business_id']);
      if (id != null && !_businessChannels.containsKey(id)) {
        ids.add(id);
      }
    }
    if (ids.isEmpty) return;

    await Future.wait(ids.map((id) async {
      final result = await _api.getBusinessCatalog(id);
      result.fold((_) {}, (data) {
        final business = Map<String, dynamic>.from(
          data['business'] as Map? ?? {},
        );
        _businessChannels[id] = (
          showInStore: business['show_instore'] == true,
          showOnline: business['show_online'] == true,
        );
      });
    }));
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> get _visibleProducts {
    if (_channelFilter == ProductChannelFilter.all) return _products;
    return _products.where((product) {
      final channel = _channelFor(product);
      return _channelFilter.matches(
        showInStore: channel.showInStore,
        showOnline: channel.showOnline,
      );
    }).toList();
  }

  ({bool showInStore, bool showOnline}) _channelFor(
    Map<String, dynamic> product,
  ) {
    final id = _asInt(product['business_id']);
    if (id != null && _businessChannels.containsKey(id)) {
      return _businessChannels[id]!;
    }
    return (showInStore: false, showOnline: true);
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
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

  @override
  Widget build(BuildContext context) {
    ref.listen(savedAddressesProvider, (previous, next) {
      if (!next.selectedLocationChangedFrom(previous)) return;
      _load();
    });

    final addresses = ref.watch(savedAddressesProvider);
    final unread = ref.watch(notificationsProvider).unreadCount;
    final cartCount = ref.watch(
      cartProvider.select((state) => state.totalQuantity),
    );
    final tt = Theme.of(context).textTheme;
    final canvas = homeCanvasOf(context);
    final bottomInset =
        kHomeFeedBottomInset + MediaQuery.paddingOf(context).bottom;
    final visible = _visibleProducts;
    final locationText = addresses.selectedAddress?.city ?? 'Add address';

    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
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
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                if (_topPicks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.ms.w,
                        AppSpacing.sm.h,
                        AppSpacing.ms.w,
                        AppSpacing.xs.h,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 22,
                            color: context.appColors.deal,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              'Top picks for you',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 148.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
                        itemCount: _topPicks.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (context, index) {
                          final product = _topPicks[index];
                          return _TopPickCard(
                            product: product,
                            onTap: () => _openProduct(product),
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
                    channelFilter: _channelFilter,
                    onChannelSelected: (filter) {
                      if (_channelFilter == filter) return;
                      setState(() => _channelFilter = filter);
                    },
                  ),
                ),
                if (visible.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                      child: AppEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: _channelFilter == ProductChannelFilter.all
                            ? 'No products yet'
                            : 'No ${_channelFilter.label.toLowerCase()} products',
                        subtitle: _channelFilter == ProductChannelFilter.all
                            ? 'Check back soon for local picks.'
                            : 'Try another filter to see more products.',
                        actionLabel: _channelFilter == ProductChannelFilter.all
                            ? null
                            : 'Show all',
                        onAction: _channelFilter == ProductChannelFilter.all
                            ? null
                            : () => setState(
                                  () => _channelFilter =
                                      ProductChannelFilter.all,
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
                        // Packed square image + meta (~3 product rows visible).
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = visible[index];
                          return _ProductGridCard(
                            product: product,
                            channel: _channelFor(product),
                            onTap: () => _openProduct(product),
                          );
                        },
                        childCount: visible.length,
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
            hintText: 'Search products',
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
    required this.channelFilter,
    required this.onChannelSelected,
  });

  final TextTheme textTheme;
  final Color backgroundColor;
  final ProductChannelFilter channelFilter;
  final ValueChanged<ProductChannelFilter> onChannelSelected;

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
                      child: _ProductChannelFilterChips(
                        selected: channelFilter,
                        onSelected: onChannelSelected,
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
    return channelFilter != oldDelegate.channelFilter ||
        textTheme != oldDelegate.textTheme ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class _ProductChannelFilterChips extends StatelessWidget {
  const _ProductChannelFilterChips({
    required this.selected,
    required this.onSelected,
  });

  final ProductChannelFilter selected;
  final ValueChanged<ProductChannelFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: ProductChannelFilter.values.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = ProductChannelFilter.values[index];
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
            ProductChannelFilter.all => Icons.grid_view_rounded,
            ProductChannelFilter.ecommerce => Icons.language_rounded,
            ProductChannelFilter.inStore => Icons.storefront_outlined,
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
class _TopPickCard extends StatelessWidget {
  const _TopPickCard({
    required this.product,
    required this.onTap,
  });

  final Map<String, dynamic> product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasDiscount = product['has_discount'] == true;
    final imageUrl = product['image_url']?.toString();
    final businessName = product['business_name']?.toString() ?? '';
    final price = _formatMoney(
      product['effective_price'] ?? product['base_price'],
    );
    final basePrice = _formatMoney(product['base_price']);
    final discountLabel = _formatDiscount(product['effective_discount_percent']);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.md,
        child: Ink(
          width: 118.w,
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
                    if (hasDiscount && discountLabel != null)
                      Positioned(
                        left: 6.w,
                        bottom: 6.h,
                        child: _DiscountBadge(label: discountLabel),
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
                      basePrice: hasDiscount ? basePrice : null,
                      emphasize: hasDiscount,
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

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({
    required this.product,
    required this.channel,
    required this.onTap,
  });

  final Map<String, dynamic> product;
  final ({bool showInStore, bool showOnline}) channel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasDiscount = product['has_discount'] == true;
    final imageUrl = product['image_url']?.toString();
    final businessName = product['business_name']?.toString() ?? '';
    final price = _formatMoney(
      product['effective_price'] ?? product['base_price'],
    );
    final basePrice = _formatMoney(product['base_price']);
    final discountLabel = _formatDiscount(product['effective_discount_percent']);
    final channelLabel = _channelLabel(channel);

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
                    if (hasDiscount && discountLabel != null)
                      Positioned(
                        left: 6.w,
                        bottom: 6.h,
                        child: _DiscountBadge(label: discountLabel),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 7.h, 8.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (businessName.isNotEmpty || channelLabel != null)
                      Text(
                        [
                          if (businessName.isNotEmpty) businessName,
                          if (channelLabel != null) channelLabel,
                        ].join(' · '),
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
                      basePrice: hasDiscount ? basePrice : null,
                      emphasize: hasDiscount,
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
            'Rs $price',
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
              'Rs $basePrice',
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

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
              fontSize: 10,
            ),
      ),
    );
  }
}

String _formatMoney(dynamic value) {
  if (value == null) return '';
  if (value is num) {
    final asDouble = value.toDouble();
    if (asDouble == asDouble.roundToDouble()) {
      return asDouble.toInt().toString();
    }
    return asDouble.toStringAsFixed(2);
  }
  final raw = value.toString().trim();
  final parsed = double.tryParse(raw);
  if (parsed == null) return raw;
  if (parsed == parsed.roundToDouble()) return parsed.toInt().toString();
  return parsed.toStringAsFixed(2);
}

String? _formatDiscount(dynamic value) {
  if (value == null) return null;
  final parsed = value is num ? value.toDouble() : double.tryParse('$value');
  if (parsed == null) return null;
  final label = parsed == parsed.roundToDouble()
      ? '${parsed.toInt()}%'
      : '${parsed.toStringAsFixed(0)}%';
  return '$label off';
}

String? _channelLabel(({bool showInStore, bool showOnline}) channel) {
  if (channel.showOnline && channel.showInStore) return 'Online & store';
  if (channel.showOnline) return 'Online';
  if (channel.showInStore) return 'In-store';
  return null;
}
