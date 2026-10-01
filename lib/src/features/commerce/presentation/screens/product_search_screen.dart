import 'dart:async';

import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/commerce_product_card.dart';
import 'package:aajhee/src/features/home/data/models/category_model.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/home/presentation/utils/category_icons.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/utils/money_format.dart';

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  static const _recentKey = 'recent_product_searches';
  static const _maxRecent = 8;

  final _api = CommerceApiService(DioService.instance);
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  List<Map<String, dynamic>> _productResults = const [];
  List<MapBranchModel> _shopResults = const [];
  List<Map<String, dynamic>> _suggestedProducts = const [];
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
      (data) {
        setState(() {
          _loadingSuggestions = false;
          _suggestedProducts = _parseProductList(data);
        });
      },
    );
  }

  List<Map<String, dynamic>> _parseProductList(Map<String, dynamic> data) {
    final raw = data['results'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
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
      (data) {
        setState(() {
          _loading = false;
          _productResults = _parseProductList(data);
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

  void _openProduct(Map<String, dynamic> product) {
    context.push(
      AppRoutes.productDetail('${product['id']}'),
      extra: product,
    );
  }

  void _openShop(MapBranchModel branch) {
    context.push(AppRoutes.businessStore, extra: branch);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final query = _controller.text.trim();
    final feed = ref.watch(homeFeedProvider);
    final categories = feed.categories;

    return Scaffold(
      backgroundColor: homeCanvasOf(context),
      appBar: AppBar(
        backgroundColor: homeCanvasOf(context),
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          onChanged: _onQueryChanged,
          onSubmitted: (value) => _search(value.trim(), persist: true),
          decoration: InputDecoration(
            hintText: 'Search shops & products',
            border: InputBorder.none,
            hintStyle: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              onPressed: () {
                _controller.clear();
                _onQueryChanged('');
              },
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
      body: query.isEmpty
          ? _IdleBody(
              recentSearches: _recentSearches,
              categories: categories,
              suggestedProducts: _suggestedProducts,
              loadingSuggestions: _loadingSuggestions,
              onRecentTap: _applyQueryAndSearch,
              onClearRecent: _clearRecentSearches,
              onCategoryTap: _applyQueryAndSearch,
              onProductTap: _openProduct,
            )
          : _loading
              ? const _SearchLoadingBody()
              : _error != null &&
                      _productResults.isEmpty &&
                      _shopResults.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => _search(query),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _productResults.isEmpty && _shopResults.isEmpty
                      ? Center(
                          child: Text(
                            'No results for “$query”',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        )
                      : _ResultsBody(
                          shops: _shopResults,
                          products: _productResults,
                          onShopTap: _openShop,
                          onProductTap: _openProduct,
                        ),
    );
  }
}

class _IdleBody extends StatelessWidget {
  const _IdleBody({
    required this.recentSearches,
    required this.categories,
    required this.suggestedProducts,
    required this.loadingSuggestions,
    required this.onRecentTap,
    required this.onClearRecent,
    required this.onCategoryTap,
    required this.onProductTap,
  });

  final List<String> recentSearches;
  final List<CategoryModel> categories;
  final List<Map<String, dynamic>> suggestedProducts;
  final bool loadingSuggestions;
  final ValueChanged<String> onRecentTap;
  final VoidCallback onClearRecent;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<Map<String, dynamic>> onProductTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        if (recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent searches',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: onClearRecent,
                child: const Text('Clear'),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final term in recentSearches)
                ActionChip(
                  avatar: Icon(
                    Icons.history_rounded,
                    size: 16.r,
                    color: cs.onSurfaceVariant,
                  ),
                  label: Text(term),
                  onPressed: () => onRecentTap(term),
                ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
        if (categories.isNotEmpty) ...[
          Text(
            'Popular categories',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final category in categories)
                ActionChip(
                  avatar: Icon(
                    categoryIconForName(category.name),
                    size: 16.r,
                    color: cs.primary,
                  ),
                  label: Text(category.name),
                  onPressed: () => onCategoryTap(category.name),
                ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
        Text(
          'Suggested for you',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10.h),
        if (loadingSuggestions)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (suggestedProducts.isEmpty)
          Text(
            'No suggestions yet',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          )
        else
          ...[
            for (var i = 0; i < suggestedProducts.length; i++) ...[
              if (i > 0) SizedBox(height: 10.h),
              _SearchProductTile(
                product: suggestedProducts[i],
                onTap: () => onProductTap(suggestedProducts[i]),
              ),
            ],
          ],
      ],
    );
  }
}

class _SearchLoadingBody extends StatelessWidget {
  const _SearchLoadingBody();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          return Material(
            color: cs.surfaceContainerLowest,
            borderRadius: AppBorders.card,
            child: Padding(
              padding: EdgeInsets.all(10.r),
              child: Row(
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: AppBorders.md,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loading product name placeholder',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Rs 0,000',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.shops,
    required this.products,
    required this.onShopTap,
    required this.onProductTap,
  });

  final List<MapBranchModel> shops;
  final List<Map<String, dynamic>> products;
  final ValueChanged<MapBranchModel> onShopTap;
  final ValueChanged<Map<String, dynamic>> onProductTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final showShops = shops.isNotEmpty;
    final showProducts = products.isNotEmpty;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        if (showShops) ...[
          Text(
            'Shops',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.h),
          for (var i = 0; i < shops.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _SearchShopTile(
              branch: shops[i],
              onTap: () => onShopTap(shops[i]),
            ),
          ],
          if (showProducts) SizedBox(height: 20.h),
        ],
        if (showProducts) ...[
          Text(
            'Products',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.h),
          for (var i = 0; i < products.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _SearchProductTile(
              product: products[i],
              onTap: () => onProductTap(products[i]),
            ),
          ],
        ],
      ],
    );
  }
}

class _SearchShopTile extends StatelessWidget {
  const _SearchShopTile({
    required this.branch,
    required this.onTap,
  });

  final MapBranchModel branch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final category = branch.categoryName.trim();

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Row(
            children: [
              StoreLogoBadge(
                name: branch.displayName,
                imageUrl: branch.logoUrl,
                size: 64,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchProductTile extends StatelessWidget {
  const _SearchProductTile({
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
    final price = formatRs(product['effective_price'] ?? product['base_price']);
    final discountPercent = product['effective_discount_percent'];

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppBorders.md,
                child: SizedBox(
                  width: 64.w,
                  height: 64.w,
                  child: CommerceProductImage(
                    imageUrl: resolveMediaUrl(imageUrl),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      hasDiscount && discountPercent != null
                          ? '$price · $discountPercent% off'
                          : price,
                      style: tt.bodySmall?.copyWith(
                        color: hasDiscount
                            ? context.appColors.deal
                            : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
