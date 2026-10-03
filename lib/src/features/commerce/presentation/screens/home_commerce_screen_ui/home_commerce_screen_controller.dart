part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

const int _kShopsTabIndex = 1;
const int _kCarouselShopLimit = 10;
const int _kCarouselProductLimit = 12;

mixin HomeCommerceScreenController on ConsumerState<HomeCommerceScreen> {
  CommerceRepository get _api => ref.read(commerceRepositoryProvider);
  DiscoveryService get _discovery => ref.read(discoveryServiceProvider);

  List<CommerceProduct> _products = const [];
  List<MapBranchModel> _nearbyBranches = const [];
  HomeFeeds _homeFeeds = const HomeFeeds();
  String? _error;
  bool _loading = true;

  /// 0 = All, 1..n = root categories (local to Explore section).
  int _exploreCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _ensureHomeFeedLoaded();
      _load();
    });
  }

  void _ensureHomeFeedLoaded() {
    final feed = ref.read(homeFeedProvider);
    if (feed.categories.isEmpty && !feed.isLoading) {
      unawaited(ref.read(homeFeedProvider.notifier).load());
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    _ensureHomeFeedLoaded();
    final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;

    final productsFuture = _api.listProducts(page: 1, pageSize: 20);
    final feedsFuture = _api.getHomeFeeds(addressId: addressId);
    final branchesFuture = _discovery.getMapBranches(
      addressId: addressId,
      page: 1,
      pageSize: 20,
    );

    final productsResult = await productsFuture;
    final feedsResult = await feedsFuture;
    final branchesResult = await branchesFuture;
    unawaited(ref.read(cartProvider.notifier).refresh());
    if (!mounted) return;

    String? error;
    var products = <CommerceProduct>[];
    var nearby = <MapBranchModel>[];
    var feeds = const HomeFeeds();

    productsResult.fold(
      (f) => error = f.message,
      (page) => products = page.products,
    );
    feedsResult.fold((_) {}, (value) => feeds = value);
    branchesResult.fold(
      (f) => error ??= f.message,
      (page) => nearby = page.results,
    );

    setState(() {
      _products = products;
      _nearbyBranches = nearby;
      _homeFeeds = feeds;
      _loading = false;
      _error = products.isEmpty && nearby.isEmpty ? error : null;
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(homeFeedProvider.notifier).load(),
      _load(),
    ]);
  }

  Set<int> _sameDayBusinessIds(List<MapBranchModel> branches) {
    return {
      for (final branch in branches)
        if (branch.treatsAsSameDay && branch.businessId > 0) branch.businessId,
    };
  }

  List<CommerceProduct> _productsForBusinessIds(Set<int> businessIds) {
    if (businessIds.isEmpty) return const [];
    return _products.where((product) {
      final id = product.businessId;
      return id != null && businessIds.contains(id);
    }).toList();
  }

  List<CommerceProduct> _todayProducts(Set<int> sameDayBusinessIds) {
    final fromShops = _productsForBusinessIds(sameDayBusinessIds);
    if (fromShops.isNotEmpty) {
      return fromShops.take(_kCarouselProductLimit).toList();
    }
    if (_homeFeeds.offers.isNotEmpty) {
      return _homeFeeds.offers.take(_kCarouselProductLimit).toList();
    }
    return _products.take(_kCarouselProductLimit).toList();
  }

  List<CommerceProduct> _popularProducts({
    Set<int> excludeIds = const {},
  }) {
    final candidates = <CommerceProduct>[
      ..._homeFeeds.trending,
      ..._homeFeeds.topPicks,
    ];
    if (candidates.isEmpty) {
      final sorted = [..._products];
      sorted.sort((a, b) {
        final aRating = a.ratingAvg;
        final bRating = b.ratingAvg;
        if (aRating == null && bRating == null) return 0;
        if (aRating == null) return 1;
        if (bRating == null) return -1;
        return bRating.compareTo(aRating);
      });
      candidates.addAll(sorted);
    }
    return _takeUniqueProducts(candidates, excludeIds: excludeIds);
  }

  List<CommerceProduct> _browseProducts({
    Set<int> excludeIds = const {},
  }) {
    return _takeUniqueProducts(_products, excludeIds: excludeIds);
  }

  List<CommerceProduct> _takeUniqueProducts(
    List<CommerceProduct> source, {
    Set<int> excludeIds = const {},
  }) {
    final seen = <int>{...excludeIds};
    final out = <CommerceProduct>[];
    for (final product in source) {
      final id = product.id;
      if (id != null && !seen.add(id)) continue;
      out.add(product);
      if (out.length >= _kCarouselProductLimit) break;
    }
    return out;
  }

  Set<int> _productIds(List<CommerceProduct> products) {
    return {
      for (final product in products)
        if (product.id != null) product.id!,
    };
  }

  List<MapBranchModel> _exploreBranches(List<CategoryModel> categories) {
    if (_exploreCategoryIndex <= 0) {
      return _nearbyBranches.take(_kCarouselShopLimit).toList();
    }
    final categoryIndex = _exploreCategoryIndex - 1;
    if (categoryIndex < 0 || categoryIndex >= categories.length) {
      return _nearbyBranches.take(_kCarouselShopLimit).toList();
    }
    final categoryId = categories[categoryIndex].id;
    return _nearbyBranches
        .where((branch) => branch.categoryId == categoryId)
        .take(_kCarouselShopLimit)
        .toList();
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

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProductSearchScreen(),
      ),
    );
  }

  void _openProduct(CommerceProduct product) {
    final id = product.id;
    if (id == null) return;
    context.push(
      AppRoutes.productDetail('$id'),
      extra: product.toJson(),
    );
  }

  Future<void> _addProductToCart(CommerceProduct product) async {
    final productId = product.id;
    if (productId == null) return;
    final branchId = product.branchId;
    final ok = await ref.read(cartProvider.notifier).addProduct(
          productId: productId,
          branchId: branchId,
        );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Added to bag')),
      );
    } else {
      final message = ref.read(cartProvider).errorMessage;
      messenger.showSnackBar(
        SnackBar(content: Text(message ?? 'Could not add to bag')),
      );
    }
  }

  void _openBranch(MapBranchModel branch) {
    context.push(AppRoutes.businessStore, extra: branch);
  }

  void _openShopsTab({int categoryIndex = 0}) {
    ref.read(homeFeedProvider.notifier).selectCategory(categoryIndex);
    ref.read(bottomNavBarControllerProvider.notifier).selectedIndex =
        _kShopsTabIndex;
  }

  void _onExploreCategorySelected(int index) {
    if (_exploreCategoryIndex == index) return;
    setState(() => _exploreCategoryIndex = index);
  }
}
