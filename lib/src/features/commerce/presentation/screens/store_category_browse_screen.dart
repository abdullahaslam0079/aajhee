import 'package:aajhee/src/features/commerce/domain/entities/commerce_product.dart';
import 'package:aajhee/src/features/commerce/domain/entities/product_page.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/commerce_repository_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/commerce_product_card.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_routes.dart';

/// Lightweight tab for store See-all browse (deals or a category).
class StoreBrowseTab {
  const StoreBrowseTab({
    required this.id,
    required this.title,
    this.categoryId,
  });

  static const dealsId = 'deals';

  final String id;
  final String title;
  final int? categoryId;

  bool get isDeals => id == dealsId;
}

class StoreCategoryBrowseArgs {
  const StoreCategoryBrowseArgs({
    required this.storeName,
    required this.tabs,
    this.branchId,
    this.businessId,
    this.initialIndex = 0,
  });

  final String storeName;
  final List<StoreBrowseTab> tabs;
  final int? branchId;
  final int? businessId;
  final int initialIndex;
}

/// Foodpanda-style store category browser with paginated product grid.
class StoreCategoryBrowseScreen extends ConsumerStatefulWidget {
  const StoreCategoryBrowseScreen({super.key, required this.args});

  final StoreCategoryBrowseArgs args;

  @override
  ConsumerState<StoreCategoryBrowseScreen> createState() =>
      _StoreCategoryBrowseScreenState();
}

class _StoreCategoryBrowseScreenState
    extends ConsumerState<StoreCategoryBrowseScreen> {
  late int _selectedIndex;
  final Map<String, _TabPageState> _pages = {};
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final max =
        widget.args.tabs.isEmpty ? 0 : widget.args.tabs.length - 1;
    _selectedIndex = widget.args.initialIndex.clamp(0, max);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureTabLoaded(_selectedIndex);
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  StoreBrowseTab? get _selected {
    if (widget.args.tabs.isEmpty) return null;
    return widget.args.tabs[_selectedIndex];
  }

  _TabPageState _stateFor(StoreBrowseTab tab) {
    return _pages.putIfAbsent(tab.id, _TabPageState.new);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _ensureTabLoaded(int index) async {
    if (widget.args.tabs.isEmpty) return;
    final tab = widget.args.tabs[index];
    final state = _stateFor(tab);
    if (state.products.isNotEmpty || state.loading || state.loadingMore) {
      return;
    }
    await _fetchPage(tab, page: 1, replace: true);
  }

  Future<void> _selectTab(int index) async {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    await _ensureTabLoaded(index);
  }

  Future<void> _loadMore() async {
    final tab = _selected;
    if (tab == null) return;
    final state = _stateFor(tab);
    if (!state.hasMore || state.loading || state.loadingMore) return;
    await _fetchPage(tab, page: state.page + 1, replace: false);
  }

  Future<void> _fetchPage(
    StoreBrowseTab tab, {
    required int page,
    required bool replace,
  }) async {
    final state = _stateFor(tab);
    setState(() {
      if (replace) {
        state.loading = true;
        state.error = null;
      } else {
        state.loadingMore = true;
      }
    });

    final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
    final api = ref.read(commerceRepositoryProvider);
    final result = tab.isDeals
        ? await api.getStoreDeals(
            branchId: widget.args.branchId,
            businessId: widget.args.businessId,
            addressId: addressId,
            page: page,
          )
        : await api.getStoreCategoryProducts(
            categoryId: tab.categoryId!,
            branchId: widget.args.branchId,
            businessId: widget.args.businessId,
            addressId: addressId,
            page: page,
          );

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          state.loading = false;
          state.loadingMore = false;
          state.error = failure.message;
        });
      },
      (ProductPage pageData) {
        setState(() {
          state.loading = false;
          state.loadingMore = false;
          state.error = null;
          state.page = page;
          state.hasMore = pageData.hasMore;
          if (replace) {
            state.products = pageData.products;
          } else {
            state.products = [...state.products, ...pageData.products];
          }
        });
      },
    );
  }

  void _openProduct(CommerceProduct product) {
    final id = product.id;
    if (id == null) return;
    final branchId = widget.args.branchId;
    final path = branchId != null
        ? '${AppRoutes.productDetail('$id')}?branch_id=$branchId'
        : AppRoutes.productDetail('$id');
    context.push(path, extra: product.toJson());
  }

  Future<void> _addToCart(CommerceProduct product) async {
    final productId = product.id;
    if (productId == null) return;
    final ok = await ref.read(cartProvider.notifier).addProduct(
          productId: productId,
          branchId: product.branchId ?? widget.args.branchId,
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final canvas = homeCanvasOf(context);
    final tabs = widget.args.tabs;
    final selected = _selected;
    final state = selected != null ? _stateFor(selected) : null;
    final products = state?.products ?? const <CommerceProduct>[];

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        title: const Text('All categories'),
      ),
      body: tabs.isEmpty
          ? const AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No categories',
              subtitle: 'This shop has not published categories yet.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 44.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: tabs.length,
                    separatorBuilder: (_, __) => SizedBox(width: 18.w),
                    itemBuilder: (context, index) {
                      final selectedTab = index == _selectedIndex;
                      return InkWell(
                        onTap: () => _selectTab(index),
                        borderRadius: AppBorders.sm,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              tabs[index].title,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: selectedTab
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: selectedTab
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 2.5,
                              width: selectedTab ? 28.w : 0,
                              decoration: BoxDecoration(
                                color: cs.onSurface,
                                borderRadius: AppBorders.full,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.55),
                ),
                Expanded(
                  child: state == null
                      ? const SizedBox.shrink()
                      : state.loading && products.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : state.error != null && products.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          state.error!,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        FilledButton(
                                          onPressed: () => _fetchPage(
                                            selected!,
                                            page: 1,
                                            replace: true,
                                          ),
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : products.isEmpty
                                  ? const AppEmptyState(
                                      icon: Icons.inventory_2_outlined,
                                      title: 'No products',
                                      subtitle:
                                          'Nothing in this category yet.',
                                    )
                                  : CustomScrollView(
                                      controller: _scrollController,
                                      physics: const BouncingScrollPhysics(
                                        parent:
                                            AlwaysScrollableScrollPhysics(),
                                      ),
                                      slivers: [
                                        SliverToBoxAdapter(
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                              16.w,
                                              16.h,
                                              16.w,
                                              10.h,
                                            ),
                                            child: Text(
                                              selected!.title,
                                              style: tt.titleLarge?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.35,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SliverPadding(
                                          padding: EdgeInsets.fromLTRB(
                                            16.w,
                                            0,
                                            16.w,
                                            28.h,
                                          ),
                                          sliver: SliverGrid(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 12.h,
                                              crossAxisSpacing: 10.w,
                                              childAspectRatio: 0.72,
                                            ),
                                            delegate:
                                                SliverChildBuilderDelegate(
                                              (context, index) {
                                                final product =
                                                    products[index];
                                                return CommerceProductCard(
                                                  product: product,
                                                  primaryAdd: true,
                                                  onTap: () =>
                                                      _openProduct(product),
                                                  onAddTap: () =>
                                                      _addToCart(product),
                                                );
                                              },
                                              childCount: products.length,
                                            ),
                                          ),
                                        ),
                                        if (state.loadingMore)
                                          SliverToBoxAdapter(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 24.h,
                                              ),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                ),
              ],
            ),
    );
  }
}

class _TabPageState {
  List<CommerceProduct> products = const [];
  int page = 0;
  bool hasMore = true;
  bool loading = false;
  bool loadingMore = false;
  String? error;
}
