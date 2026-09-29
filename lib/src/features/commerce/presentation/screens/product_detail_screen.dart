import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/utils/money_format.dart';

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
  List<Map<String, dynamic>> _suggestions = const [];
  List<Map<String, dynamic>> _reviews = const [];
  bool _loading = true;
  bool _adding = false;

  int get _productId => int.parse(widget.productId);

  @override
  void initState() {
    super.initState();
    _product = widget.initial;
    _load();
  }

  Future<void> _load() async {
    await _api.viewProduct(_productId);
    final results = await Future.wait([
      _api.getProduct(_productId),
      _api.listProducts(page: 1, pageSize: 12),
      _api.getProductReviews(_productId, page: 1),
    ]);
    if (!mounted) return;

    final productResult = results[0];
    final suggestionsResult = results[1];
    final reviewsResult = results[2];

    productResult.fold(
      (f) {
        setState(() => _loading = false);
        if (_product == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.message)),
          );
        }
      },
      (p) => setState(() {
        _product = p;
        _loading = false;
      }),
    );

    suggestionsResult.fold((_) {}, (data) {
      final raw = data['results'];
      if (raw is! List) return;
      final list = raw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((p) {
            final id = p['id'];
            return id != _productId &&
                id?.toString() != widget.productId &&
                !(id is num && id.toInt() == _productId);
          })
          .take(10)
          .toList();
      if (!mounted) return;
      setState(() => _suggestions = list);
    });

    reviewsResult.fold((_) {}, (data) {
      final raw = data['results'];
      if (raw is! List) return;
      final list = raw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (!mounted) return;
      setState(() => _reviews = list);
    });
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  MapBranchModel? _branchForBusiness(int? businessId) {
    if (businessId == null || businessId <= 0) return null;
    final branches = ref.read(homeFeedProvider).branches;
    for (final branch in branches) {
      if (branch.businessId == businessId) return branch;
    }
    return null;
  }

  bool _isVerifiedSeller(Map<String, dynamic> product, MapBranchModel? branch) {
    if (branch?.isVerified ?? false) return true;
    if (product['is_verified'] == true || product['verified'] == true) {
      return true;
    }
    final business = product['business'];
    if (business is Map) {
      if (business['is_verified'] == true || business['verified'] == true) {
        return true;
      }
    }
    return false;
  }

  dynamic _deliveryFeeValue(
    Map<String, dynamic> product,
    MapBranchModel? branch,
  ) {
    final fromProduct = product['delivery_fee'] ??
        product['same_day_delivery_fee'];
    if (fromProduct != null) return fromProduct;

    final business = product['business'];
    if (business is Map) {
      final fromBusiness =
          business['delivery_fee'] ?? business['same_day_delivery_fee'];
      if (fromBusiness != null) return fromBusiness;
    }

    return branch?.deliveryFee;
  }

  bool _supportsSameDay(
    Map<String, dynamic> product,
    MapBranchModel? branch,
  ) {
    if (branch != null) return branch.treatsAsSameDay;

    final business = product['business'];
    if (business is Map) {
      if (business['supports_same_day'] == true ||
          business['same_day_enabled'] == true ||
          business['same_day_delivery'] == true) {
        return true;
      }
      if (business['supports_same_day'] == false) return false;
      final fulfillment =
          business['fulfillment_types'] ?? business['fulfillment_modes'];
      if (fulfillment is List &&
          fulfillment.any((e) => e.toString() == 'local_same_day')) {
        return true;
      }
    }

    if (product['supports_same_day'] == true ||
        product['same_day_enabled'] == true ||
        product['same_day_delivery'] == true) {
      return true;
    }
    return false;
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
        branch: _branchForBusiness(businessId),
      ),
    );
  }

  void _openProduct(Map<String, dynamic> product) {
    final id = product['id'];
    if (id == null) return;
    context.push(
      AppRoutes.productDetail('$id'),
      extra: product,
    );
  }

  Future<void> _addToCart() async {
    final product = _product;
    if (product == null || _adding) return;
    setState(() => _adding = true);
    final ok = await ref.read(cartProvider.notifier).addProduct(
          productId: _asInt(product['id']) ?? _productId,
          branchId: widget.branchId,
        );
    if (!mounted) return;
    setState(() => _adding = false);
    if (!ok) {
      final message = ref.read(cartProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not add to cart')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.push(AppRoutes.cart),
        ),
      ),
    );
  }

  Future<void> _changeQuantity({
    required int itemId,
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
    final hasDiscountFlag = product?['has_discount'] == true;
    final discountPercent = _discountPercent(
      product?['effective_discount_percent'],
    );
    final showDiscount =
        hasDiscountFlag && discountPercent != null && discountPercent > 0;
    final cartState = ref.watch(cartProvider);
    final cartItem = cartState.itemForProduct(
      _productId,
      branchId: widget.branchId,
    );
    final cartQty = _cartQuantity(cartItem);
    final cartItemId = _asInt(cartItem?['id']);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final canvas = homeCanvasOf(context);
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
    final matchingBranch = businessId == null
        ? null
        : ref.watch(
            homeFeedProvider.select(
              (state) {
                for (final branch in state.branches) {
                  if (branch.businessId == businessId) return branch;
                }
                return null;
              },
            ),
          );
    final city = ref
            .watch(savedAddressesProvider)
            .selectedAddress
            ?.city
            .trim() ??
        '';
    final description = product?['description']?.toString().trim() ?? '';
    final detailed =
        product?['detailed_description']?.toString().trim() ?? '';
    final price = formatRs(
      product?['effective_price'] ?? product?['base_price'],
    );
    final basePrice = formatRsOrNull(product?['base_price']);
    final discountLabel = showDiscount
        ? _formatDiscount(product?['effective_discount_percent'])
        : null;
    final busyAdding = _adding;
    final isVerified =
        product != null && _isVerifiedSeller(product, matchingBranch);
    final sameDayAvailable =
        product != null && _supportsSameDay(product, matchingBranch);
    final feeValue =
        product == null ? null : _deliveryFeeValue(product, matchingBranch);
    final feeLabel = formatRsOrNull(feeValue);

    final moreFromShop = <Map<String, dynamic>>[];
    final similarProducts = <Map<String, dynamic>>[];
    for (final item in _suggestions) {
      final itemBusinessId = _asInt(item['business_id']);
      if (businessId != null &&
          itemBusinessId != null &&
          itemBusinessId == businessId) {
        moreFromShop.add(item);
      } else {
        similarProducts.add(item);
      }
    }

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        title: Text(
          product?['name']?.toString() ?? 'Product',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
      bottomNavigationBar: product == null
          ? null
          : _BottomCartBar(
              inCart: cartItemId != null,
              quantity: cartQty,
              busy: busyAdding,
              priceLabel: price,
              onAdd: busyAdding ? null : _addToCart,
              onViewCart: () => context.push(AppRoutes.cart),
              onDecrease: cartItemId == null
                  ? null
                  : () => _changeQuantity(
                        itemId: cartItemId,
                        nextQty: cartQty - 1,
                      ),
              onIncrease: cartItemId == null
                  ? null
                  : () => _changeQuantity(
                        itemId: cartItemId,
                        nextQty: cartQty + 1,
                      ),
              onRemove: cartItemId == null
                  ? null
                  : () => _changeQuantity(
                        itemId: cartItemId,
                        nextQty: 0,
                      ),
            ),
      body: _loading && product == null
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? const Center(child: Text('Product not found'))
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _HeroImage(
                        imageUrl: product['image_url']?.toString(),
                        discountLabel: discountLabel,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name']?.toString() ?? '',
                              style: tt.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                                letterSpacing: -0.3,
                                height: 1.15,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            _PriceBlock(
                              price: price,
                              basePrice: showDiscount ? basePrice : null,
                              emphasize: showDiscount,
                            ),
                            SizedBox(height: 10.h),
                            _ProductRatingRow(product: product),
                            SizedBox(height: 12.h),
                            _DeliveryInfoBox(
                              city: city,
                              sameDayAvailable: sameDayAvailable,
                              feeLabel: feeLabel,
                            ),
                            if (businessName.isNotEmpty) ...[
                              SizedBox(height: 18.h),
                              _SoldByRow(
                                businessName: businessName,
                                logoUrl: logoUrl,
                                isVerified: isVerified,
                                onTap: () => _openStore(product),
                              ),
                            ],
                            if (description.isNotEmpty ||
                                detailed.isNotEmpty) ...[
                              SizedBox(height: 22.h),
                              Text(
                                'About this product',
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              if (description.isNotEmpty)
                                Text(
                                  description,
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.45,
                                  ),
                                ),
                              if (detailed.isNotEmpty) ...[
                                if (description.isNotEmpty)
                                  SizedBox(height: 10.h),
                                Text(
                                  detailed,
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ],
                            if (_reviews.isNotEmpty) ...[
                              SizedBox(height: 22.h),
                              Text(
                                'Customer reviews',
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              ..._reviews.take(5).map(
                                    (review) => Padding(
                                      padding: EdgeInsets.only(bottom: 12.h),
                                      child: _ReviewCard(review: review),
                                    ),
                                  ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (moreFromShop.isNotEmpty)
                      ..._suggestionSection(
                        title: 'More from this shop',
                        items: moreFromShop,
                        tt: tt,
                        cs: cs,
                      ),
                    if (similarProducts.isNotEmpty)
                      ..._suggestionSection(
                        title: 'Similar products',
                        items: similarProducts,
                        tt: tt,
                        cs: cs,
                      ),
                    SliverToBoxAdapter(child: SizedBox(height: 28.h)),
                  ],
                ),
    );
  }

  List<Widget> _suggestionSection({
    required String title,
    required List<Map<String, dynamic>> items,
    required TextTheme tt,
    required ColorScheme cs,
  }) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 10.h),
          child: Text(
            title,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 196.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final item = items[index];
              return _SuggestionCard(
                product: item,
                onTap: () => _openProduct(item),
              );
            },
          ),
        ),
      ),
    ];
  }

  static int _cartQuantity(Map<String, dynamic>? cartItem) {
    if (cartItem == null) return 0;
    final qty = cartItem['quantity'];
    if (qty is int) return qty;
    if (qty is num) return qty.toInt();
    return 1;
  }
}

class _DeliveryInfoBox extends StatelessWidget {
  const _DeliveryInfoBox({
    required this.city,
    required this.sameDayAvailable,
    this.feeLabel,
  });

  final String city;
  final bool sameDayAvailable;
  final String? feeLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    String? sameDayLine;
    if (sameDayAvailable) {
      if (city.isNotEmpty && feeLabel != null) {
        sameDayLine = 'Delivery today in $city · $feeLabel';
      } else if (city.isNotEmpty) {
        sameDayLine = 'Delivery today in $city';
      } else if (feeLabel != null) {
        sameDayLine = 'Delivery today · $feeLabel';
      } else {
        sameDayLine = 'Delivery today';
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: AppBorders.md,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sameDayLine != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 18,
                  color: cs.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    sameDayLine,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.payments_outlined,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Cash on delivery available',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.imageUrl,
    this.discountLabel,
  });

  final String? imageUrl;
  final String? discountLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    // Compact marketplace frame: always filled, no letterboxing.
    final height = (width * 0.72).clamp(200.0, 260.0);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: cs.surfaceContainerHighest,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: height,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
          ),
          if (discountLabel != null)
            Positioned(
              top: 10.h,
              left: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: context.appColors.deal,
                  borderRadius: AppBorders.full,
                ),
                child: Text(
                  discountLabel!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.appColors.onDeal,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
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
    final deal = context.appColors.deal;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          price,
          style: tt.headlineSmall?.copyWith(
            color: emphasize ? deal : cs.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            height: 1.1,
          ),
        ),
        if (basePrice != null && basePrice!.isNotEmpty) ...[
          SizedBox(width: 10.w),
          Text(
            basePrice!,
            style: tt.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _SoldByRow extends StatelessWidget {
  const _SoldByRow({
    required this.businessName,
    required this.logoUrl,
    required this.onTap,
    this.isVerified = false,
  });

  final String businessName;
  final String? logoUrl;
  final VoidCallback onTap;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.md,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppBorders.md,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                StoreLogoBadge(
                  name: businessName,
                  imageUrl: logoUrl,
                  size: 40,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sold by',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              businessName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          if (isVerified) ...[
                            SizedBox(width: 6.w),
                            const _VerifiedChip(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  'Visit store',
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(Icons.chevron_right_rounded, color: cs.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: AppBorders.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 12, color: cs.primary),
          SizedBox(width: 3.w),
          Text(
            'Verified',
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCartBar extends StatelessWidget {
  const _BottomCartBar({
    required this.inCart,
    required this.quantity,
    required this.busy,
    required this.priceLabel,
    required this.onAdd,
    required this.onViewCart,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final bool inCart;
  final int quantity;
  final bool busy;
  final String priceLabel;
  final VoidCallback? onAdd;
  final VoidCallback onViewCart;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      elevation: 8,
      color: cs.surfaceContainerLowest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          child: inCart
              ? Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh.withValues(alpha: 0.7),
                          borderRadius: AppBorders.button,
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            _QtyIconButton(
                              icon: quantity <= 1
                                  ? Icons.delete_outline_rounded
                                  : Icons.remove_rounded,
                              onPressed: quantity <= 1 ? onRemove : onDecrease,
                              tone: quantity <= 1 ? cs.error : cs.onSurface,
                            ),
                            Expanded(
                              child: Text(
                                '$quantity',
                                textAlign: TextAlign.center,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _QtyIconButton(
                              icon: Icons.add_rounded,
                              onPressed: onIncrease,
                              tone: cs.onSurface,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: FilledButton(
                        onPressed: onViewCart,
                        style: FilledButton.styleFrom(
                          minimumSize: Size.fromHeight(48.h),
                        ),
                        child: const Text('View cart'),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FilledButton(
                    onPressed: onAdd,
                    child: busy
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: cs.onPrimary,
                            ),
                          )
                        : Text(
                            'Add to cart · $priceLabel',
                            style: tt.titleSmall?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _QtyIconButton extends StatelessWidget {
  const _QtyIconButton({
    required this.icon,
    required this.onPressed,
    required this.tone,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: tone),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.product,
    required this.onTap,
  });

  final Map<String, dynamic> product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final discountPercent =
        _discountPercent(product['effective_discount_percent']);
    final hasDiscount = product['has_discount'] == true &&
        discountPercent != null &&
        discountPercent > 0;
    final imageUrl = product['image_url']?.toString();
    final price = formatRs(
      product['effective_price'] ?? product['base_price'],
    );
    final discountLabel = hasDiscount
        ? _formatDiscount(product['effective_discount_percent'])
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.md,
        child: Ink(
          width: 128.w,
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
                      child: ColoredBox(
                        color: cs.surfaceContainerHighest,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Icon(
                                Icons.image_outlined,
                                color: cs.onSurfaceVariant,
                              ),
                      ),
                    ),
                    if (discountLabel != null)
                      Positioned(
                        left: 6.w,
                        bottom: 6.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.appColors.deal,
                            borderRadius: AppBorders.full,
                          ),
                          child: Text(
                            discountLabel,
                            style: tt.labelSmall?.copyWith(
                              color: context.appColors.onDeal,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelLarge?.copyWith(
                        color: hasDiscount
                            ? context.appColors.deal
                            : cs.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
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

class _ProductRatingRow extends StatelessWidget {
  const _ProductRatingRow({required this.product});

  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final count = int.tryParse('${product['rating_count'] ?? 0}') ?? 0;
    final avg = double.tryParse('${product['rating_avg'] ?? 0}') ?? 0.0;
    if (count <= 0) {
      return Text(
        'No ratings yet',
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      );
    }
    final filled = avg.round().clamp(0, 5);
    return Row(
      children: [
        ...List.generate(
          5,
          (i) => Icon(
            i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18.sp,
            color: const Color(0xFFE6A817),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '${avg.toStringAsFixed(1)} ($count)',
          style: tt.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rating = int.tryParse('${review['rating'] ?? 0}') ?? 0;
    final comment = review['comment']?.toString().trim() ?? '';
    final name = review['user_display_name']?.toString() ?? 'Customer';
    final reply = review['merchant_reply']?.toString().trim() ?? '';
    final images = ((review['images'] as List?) ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: AppBorders.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14.sp,
                  color: const Color(0xFFE6A817),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  name,
                  style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: AppBorders.full,
                ),
                child: Text(
                  'Verified',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(comment, style: tt.bodyMedium),
          ],
          if (images.isNotEmpty) ...[
            SizedBox(height: 8.h),
            SizedBox(
              height: 64.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final url = images[i]['image_url']?.toString() ?? '';
                  if (url.isEmpty) return const SizedBox.shrink();
                  return ClipRRect(
                    borderRadius: AppBorders.sm,
                    child: Image.network(
                      url,
                      width: 64.w,
                      height: 64.h,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
          if (reply.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: AppBorders.sm,
              ),
              child: Text(
                'Store reply: $reply',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

double? _discountPercent(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

String? _formatDiscount(dynamic value) {
  final parsed = _discountPercent(value);
  if (parsed == null || parsed <= 0) return null;
  final label = parsed == parsed.roundToDouble()
      ? '${parsed.toInt()}%'
      : '${parsed.toStringAsFixed(0)}%';
  return '$label off';
}
