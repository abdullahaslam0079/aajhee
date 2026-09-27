import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initial,
    this.branchId,
  });

  final String productId;
  final Map<String, dynamic>? initial;
  final int? branchId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final _api = CommerceApiService(DioService.instance);
  Map<String, dynamic>? _product;
  bool _loading = true;

  int get _productId => int.parse(widget.productId);

  @override
  void initState() {
    super.initState();
    _product = widget.initial;
    _load();
  }

  Future<void> _load() async {
    await _api.viewProduct(_productId);
    final result = await _api.getProduct(_productId);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        if (_product == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.message)),
          );
        }
      }),
      (p) => setState(() {
        _product = p;
        _loading = false;
      }),
    );
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  void _openStore(Map<String, dynamic> product) {
    final businessId = _asInt(product['business_id']);
    if (businessId == null) return;
    final branchIds = product['branch_ids'];
    var branchId = widget.branchId;
    if (branchId == null && branchIds is List && branchIds.isNotEmpty) {
      branchId = _asInt(branchIds.first);
    }
    final logoUrl = ref.read(homeFeedProvider).logoUrlForBusiness(businessId);
    context.push(
      AppRoutes.businessStore,
      extra: StoreCatalogArgs(
        businessId: businessId,
        branchId: branchId,
        businessName: product['business_name']?.toString(),
        logoUrl: logoUrl,
      ),
    );
  }

  Future<void> _addToCart() async {
    final product = _product;
    if (product == null) return;
    final ok = await ref.read(cartProvider.notifier).addProduct(
          productId: product['id'] as int,
          branchId: widget.branchId,
        );
    if (!mounted) return;
    if (!ok) {
      final message = ref.read(cartProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not add to cart')),
      );
    }
  }

  Future<void> _changeQuantity({
    required int itemId,
    required int currentQty,
    required int nextQty,
  }) async {
    final notifier = ref.read(cartProvider.notifier);
    final ok = nextQty < 1
        ? await notifier.remove(itemId)
        : await notifier.setQuantity(itemId, nextQty);
    if (!mounted) return;
    if (!ok) {
      final message = ref.read(cartProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not update cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final hasDiscount = product?['has_discount'] == true;
    final cartState = ref.watch(cartProvider);
    final cartItem = cartState.itemForProduct(
      _productId,
      branchId: widget.branchId,
    );
    final cartQty = cartItem == null
        ? 0
        : (cartItem['quantity'] is int
            ? cartItem['quantity'] as int
            : (cartItem['quantity'] is num
                ? (cartItem['quantity'] as num).toInt()
                : 1));
    final cartItemId = cartItem?['id'] as int?;
    final updating = cartState.isUpdating;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final totalInCart = cartState.totalQuantity;
    final businessId = _asInt(product?['business_id']);
    final businessName = product?['business_name']?.toString().trim() ?? '';
    final logoUrl = businessId == null
        ? null
        : ref.watch(
            homeFeedProvider.select(
              (state) => state.logoUrlForBusiness(businessId),
            ),
          );

    return Scaffold(
      backgroundColor: homeCanvasOf(context),
      appBar: AppBar(
        backgroundColor: homeCanvasOf(context),
        title: Text(product?['name']?.toString() ?? 'Product'),
        actions: [
          IconButton(
            tooltip: 'Cart',
            onPressed: () => context.push(AppRoutes.cart),
            icon: Badge(
              isLabelVisible: totalInCart > 0,
              label: Text('$totalInCart'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: cartItemId == null
              ? SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        updating || product == null ? null : _addToCart,
                    child: updating
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onPrimary,
                            ),
                          )
                        : const Text('Add to cart'),
                  ),
                )
              : _CartQuantityBar(
                  quantity: cartQty,
                  updating: updating,
                  onDelete: () => _changeQuantity(
                    itemId: cartItemId,
                    currentQty: cartQty,
                    nextQty: 0,
                  ),
                  onDecrease: () => _changeQuantity(
                    itemId: cartItemId,
                    currentQty: cartQty,
                    nextQty: cartQty - 1,
                  ),
                  onIncrease: () => _changeQuantity(
                    itemId: cartItemId,
                    currentQty: cartQty,
                    nextQty: cartQty + 1,
                  ),
                ),
        ),
      ),
      body: _loading && product == null
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? const Center(child: Text('Product not found'))
              : ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                  children: [
                    if (businessName.isNotEmpty) ...[
                      Material(
                        color: cs.surfaceContainerLowest,
                        borderRadius: AppBorders.card,
                        child: InkWell(
                          onTap: () => _openStore(product),
                          borderRadius: AppBorders.card,
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: AppBorders.card,
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Row(
                                children: [
                                  StoreLogoBadge(
                                    name: businessName,
                                    imageUrl: logoUrl,
                                    size: 44,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          businessName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: tt.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: cs.onSurface,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'View store',
                                          style: tt.labelMedium?.copyWith(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: cs.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],
                    AspectRatio(
                      aspectRatio: 1.2,
                      child: ClipRRect(
                        borderRadius: AppBorders.card,
                        child: ColoredBox(
                          color: cs.surfaceContainerHighest,
                          child: product['image_url'] != null
                              ? Image.network(
                                  product['image_url'].toString(),
                                  fit: BoxFit.cover,
                                )
                              : const Center(
                                  child: Icon(Icons.image_outlined),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      product['name']?.toString() ?? '',
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      hasDiscount
                          ? 'Rs ${product['effective_price']}  (${product['effective_discount_percent']}% off · was Rs ${product['base_price']})'
                          : 'Rs ${product['base_price']}',
                      style: tt.titleMedium?.copyWith(
                        color: hasDiscount
                            ? context.appColors.deal
                            : cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      product['description']?.toString() ?? '',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        height: 1.4,
                      ),
                    ),
                    if ((product['detailed_description'] ?? '')
                        .toString()
                        .isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Text(
                        product['detailed_description'].toString(),
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _CartQuantityBar extends StatelessWidget {
  const _CartQuantityBar({
    required this.quantity,
    required this.updating,
    required this.onDelete,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final bool updating;
  final VoidCallback onDelete;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppBorders.button,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Remove from cart',
            onPressed: updating ? null : onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: cs.error),
          ),
          const Spacer(),
          _QtyControlButton(
            icon: Icons.remove_rounded,
            onPressed: updating ? null : onDecrease,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: updating
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  )
                : Text(
                    '$quantity',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
          ),
          _QtyControlButton(
            icon: Icons.add_rounded,
            onPressed: updating ? null : onIncrease,
          ),
        ],
      ),
    );
  }
}

class _QtyControlButton extends StatelessWidget {
  const _QtyControlButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primary,
      borderRadius: AppBorders.sm,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppBorders.sm,
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Icon(
            icon,
            color: onPressed == null
                ? cs.onPrimary.withValues(alpha: 0.4)
                : cs.onPrimary,
          ),
        ),
      ),
    );
  }
}
