part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with ProductDetailScreenController {
  Widget build(BuildContext context) {
    final product = _product;
    final hasDiscountFlag = product?['has_discount'] == true;
    final discountPercent = _discountPercent(
      product?['effective_discount_percent'],
    );
    final showDiscount =
        hasDiscountFlag && discountPercent != null && discountPercent > 0;
    final cartState = ref.watch(cartProvider);
    final cartItem = cartState.lineForProduct(
      _productId,
      branchId: widget.branchId,
    );
    final cartQty = cartItem?.quantity ?? 0;
    final cartItemId = cartItem?.id;
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
    final city =
        ref.watch(savedAddressesProvider).selectedAddress?.city.trim() ?? '';
    final description = product?['description']?.toString().trim() ?? '';
    final detailed = product?['detailed_description']?.toString().trim() ?? '';
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
}
