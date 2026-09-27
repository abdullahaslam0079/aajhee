import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartProvider.notifier).refresh());
  }

  Map<String, dynamic> _productOf(Map<String, dynamic> item) {
    return Map<String, dynamic>.from(item['product'] as Map? ?? {});
  }

  Future<void> _updateQuantity(Map<String, dynamic> item, int nextQty) async {
    final id = item['id'];
    if (id is! int) return;
    final ok = await ref.read(cartProvider.notifier).setQuantity(id, nextQty);
    if (!mounted || ok) return;
    final message = ref.read(cartProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Could not update cart')),
    );
  }

  void _openProduct(Map<String, dynamic> item) {
    final product = _productOf(item);
    final productId = product['id'] ?? item['product_id'];
    if (productId == null) return;
    final branchId = item['branch_id'] as int?;
    final path = branchId != null
        ? '${AppRoutes.productDetail('$productId')}?branch_id=$branchId'
        : AppRoutes.productDetail('$productId');
    context.push(path, extra: product.isEmpty ? null : product);
  }

  void _checkout() {
    if (ref.read(cartProvider).items.isEmpty) return;
    context.push(AppRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cartState = ref.watch(cartProvider);
    final items = cartState.items;
    final subtotal = cartState.subtotal ?? '0';
    final itemCount = cartState.totalQuantity;
    final updating = cartState.isUpdating;

    return Scaffold(
      backgroundColor: homeCanvasOf(context),
      appBar: AppBar(
        backgroundColor: homeCanvasOf(context),
        title: const Text('Cart'),
      ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          Text(
                            itemCount == 1 ? '1 item' : '$itemCount items',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Subtotal',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Rs $subtotal',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _checkout,
                        child: Text('Checkout · Rs $subtotal'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: cartState.isLoading && items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? AppEmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your cart is empty',
                  subtitle: 'Browse products and add something you like.',
                  actionLabel: 'Continue shopping',
                  onAction: () => context.pop(),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(cartProvider.notifier).refresh(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final product = _productOf(item);
                      return _CartItemCard(
                        item: item,
                        product: product,
                        updating: updating,
                        onOpen: () => _openProduct(item),
                        onDecrease: () {
                          final qty = item['quantity'];
                          final current = qty is int
                              ? qty
                              : (qty is num ? qty.toInt() : 1);
                          _updateQuantity(item, current - 1);
                        },
                        onIncrease: () {
                          final qty = item['quantity'];
                          final current = qty is int
                              ? qty
                              : (qty is num ? qty.toInt() : 1);
                          _updateQuantity(item, current + 1);
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.product,
    required this.updating,
    required this.onOpen,
    required this.onDecrease,
    required this.onIncrease,
  });

  final Map<String, dynamic> item;
  final Map<String, dynamic> product;
  final bool updating;
  final VoidCallback onOpen;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final appColors = context.appColors;

    final name = product['name']?.toString().trim();
    final displayName =
        (name != null && name.isNotEmpty) ? name : 'Product';
    final businessName = product['business_name']?.toString().trim() ?? '';
    final imageUrl = product['image_url']?.toString();
    final hasDiscount = product['has_discount'] == true;
    final unitPrice = item['unit_price'] ??
        product['effective_price'] ??
        product['base_price'];
    final lineTotal = item['line_total'] ?? unitPrice;
    final qty = item['quantity'] is int
        ? item['quantity'] as int
        : (item['quantity'] is num
            ? (item['quantity'] as num).toInt()
            : 1);

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.card,
      child: InkWell(
        onTap: onOpen,
        borderRadius: AppBorders.card,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppBorders.card,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: AppBorders.md,
                  child: SizedBox(
                    width: 88.w,
                    height: 88.w,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: cs.surfaceContainerHighest,
                              child: Icon(
                                Icons.image_outlined,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          )
                        : ColoredBox(
                            color: cs.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_outlined,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (businessName.isNotEmpty) ...[
                        Text(
                          businessName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],
                      Text(
                        displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        hasDiscount
                            ? 'Rs $unitPrice · ${product['effective_discount_percent']}% off'
                            : 'Rs $unitPrice',
                        style: tt.bodyMedium?.copyWith(
                          color: hasDiscount ? appColors.deal : cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          _QtyButton(
                            icon: Icons.remove_rounded,
                            onPressed: updating ? null : onDecrease,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: updating
                                ? SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.primary,
                                    ),
                                  )
                                : Text(
                                    '$qty',
                                    style: tt.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                    ),
                                  ),
                          ),
                          _QtyButton(
                            icon: Icons.add_rounded,
                            onPressed: updating ? null : onIncrease,
                          ),
                          const Spacer(),
                          Text(
                            'Rs $lineTotal',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Text(
                            'View details',
                            style: tt.labelMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: cs.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: AppBorders.sm,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppBorders.sm,
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Icon(
            icon,
            size: 18,
            color: onPressed == null
                ? cs.onSurface.withValues(alpha: 0.28)
                : cs.onSurface,
          ),
        ),
      ),
    );
  }
}
