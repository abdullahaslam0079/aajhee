part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

mixin HomeCommerceScreenController on ConsumerState<HomeCommerceScreen> {
  CommerceRepository get _api => ref.read(commerceRepositoryProvider);
  final _scrollController = ScrollController();

  List<CommerceProduct> _products = const [];
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

  int? _lastProductCategoryId;

  void _syncProductsToCategory(HomeFeedState feed) {
    final categoryId = feed.selectedCategoryId;
    if (categoryId == _lastProductCategoryId && _products.isNotEmpty) return;
    _lastProductCategoryId = categoryId;
    unawaited(_load());
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
    final categoryId = ref.read(homeFeedProvider).selectedCategoryId;
    _lastProductCategoryId = categoryId;
    final productsResult = await _api.listProducts(
      page: 1,
      pageSize: 20,
      categoryId: categoryId,
    );
    unawaited(ref.read(cartProvider.notifier).refresh());
    if (!mounted) return;

    String? error;
    var products = <CommerceProduct>[];
    var hasMore = false;

    productsResult.fold(
      (f) => error = f.message,
      (page) {
        products = page.products;
        hasMore = page.hasMore;
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
    final categoryId = ref.read(homeFeedProvider).selectedCategoryId;
    final result = await _api.listProducts(
      page: nextPage,
      pageSize: 20,
      categoryId: categoryId,
    );
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loadingMore = false),
      (page) {
        setState(() {
          _products = _dedupeById([..._products, ...page.products]);
          _page = nextPage;
          _hasMore = page.hasMore;
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

  List<CommerceProduct> _dedupeById(List<CommerceProduct> items) {
    final seen = <Object?>{};
    final out = <CommerceProduct>[];
    for (final item in items) {
      final id = item.id;
      if (id != null && !seen.add(id)) continue;
      out.add(item);
    }
    return out;
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

  List<CommerceProduct> _applyListFilter(
    List<CommerceProduct> products, {
    required Set<int> sameDayBusinessIds,
  }) {
    switch (_listFilter) {
      case ProductListFilter.all:
        return products;
      case ProductListFilter.sameDay:
        if (sameDayBusinessIds.isEmpty) return const [];
        return products.where((product) {
          final id = product.businessId;
          return id != null && sameDayBusinessIds.contains(id);
        }).toList();
      case ProductListFilter.topRated:
        final sorted = [...products];
        sorted.sort((a, b) {
          final aRating = a.ratingAvg;
          final bRating = b.ratingAvg;
          if (aRating == null && bRating == null) return 0;
          if (aRating == null) return 1;
          if (bRating == null) return -1;
          return bRating.compareTo(aRating);
        });
        return sorted;
      case ProductListFilter.priceLowToHigh:
        final sorted = [...products];
        sorted.sort((a, b) => a.sortPrice.compareTo(b.sortPrice));
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
}
