part of 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';

mixin ProductSearchScreenController on ConsumerState<ProductSearchScreen> {
  static const _recentKey = 'recent_product_searches';
  static const _maxRecent = 8;

  CommerceRepository get _api => ref.read(commerceRepositoryProvider);
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  List<CommerceProduct> _productResults = const [];
  List<MapBranchModel> _shopResults = const [];
  List<CommerceProduct> _suggestedProducts = const [];
  List<String> _recentSearches = const [];

  Timer? _debounce;
  bool _loading = false;
  bool _loadingSuggestions = false;
  String? _error;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _focusNode.requestFocus();
      _loadRecentSearches();
      _loadSuggestedProducts();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_recentKey) ?? const <String>[];
    if (!mounted) return;
    setState(() => _recentSearches = stored);
  }

  Future<void> _persistRecent(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final next = <String>[
      trimmed,
      ..._recentSearches.where(
        (item) => item.toLowerCase() != trimmed.toLowerCase(),
      ),
    ].take(_maxRecent).toList();

    setState(() => _recentSearches = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, next);
  }

  Future<void> _clearRecentSearches() async {
    setState(() => _recentSearches = const []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
  }

  Future<void> _loadSuggestedProducts() async {
    if (_loadingSuggestions) return;
    setState(() => _loadingSuggestions = true);

    final result = await _api.listProducts(page: 1, pageSize: 8);
    if (!mounted) return;

    result.fold(
      (_) => setState(() {
        _loadingSuggestions = false;
        _suggestedProducts = const [];
      }),
      (page) {
        setState(() {
          _loadingSuggestions = false;
          _suggestedProducts = page.products;
        });
      },
    );
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      _search(value.trim());
    });
  }

  void _applyQueryAndSearch(String query) {
    _controller
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    _search(query.trim(), persist: true);
  }

  Future<void> _search(String query, {bool persist = false}) async {
    if (query == _lastQuery &&
        (_productResults.isNotEmpty || _shopResults.isNotEmpty)) {
      return;
    }
    _lastQuery = query;

    if (query.isEmpty) {
      setState(() {
        _productResults = const [];
        _shopResults = const [];
        _loading = false;
        _error = null;
      });
      return;
    }

    if (persist) {
      unawaited(_persistRecent(query));
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final shops = _filterShops(query);
    final result = await _api.listProducts(page: 1, pageSize: 40, query: query);
    if (!mounted || query != _lastQuery) return;

    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
        _productResults = const [];
        _shopResults = shops;
      }),
      (page) {
        setState(() {
          _loading = false;
          _productResults = page.products;
          _shopResults = shops;
        });
        unawaited(_persistRecent(query));
      },
    );
  }

  List<MapBranchModel> _filterShops(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final branches = ref.read(homeFeedProvider).branches;
    return branches.where((branch) {
      final name = branch.displayName.toLowerCase();
      final category = branch.categoryName.toLowerCase();
      return name.contains(q) || category.contains(q);
    }).toList();
  }

  void _openProduct(CommerceProduct product) {
    final id = product.id;
    if (id == null) return;
    context.push(
      AppRoutes.productDetail('$id'),
      extra: product.toJson(),
    );
  }

  void _openShop(MapBranchModel branch) {
    context.push(AppRoutes.businessStore, extra: branch);
  }
}
