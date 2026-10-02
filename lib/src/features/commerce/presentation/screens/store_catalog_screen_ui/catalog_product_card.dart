part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({
    required this.product,
    this.branchId,
  });

  final Map<String, dynamic> product;
  final int? branchId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final discountRaw = product['effective_discount_percent'];
    final discountPercent = discountRaw is num
        ? discountRaw.toDouble()
        : double.tryParse('${discountRaw ?? ''}');
    final hasDiscount = product['has_discount'] == true &&
        discountPercent != null &&
        discountPercent > 0;
    final imageUrl = product['image_url']?.toString();
    final price = formatRs(
      product['effective_price'] ?? product['base_price'],
    );
    final discountLabel = hasDiscount
        ? (discountPercent == discountPercent.roundToDouble()
            ? '${discountPercent.toInt()}% off'
            : '${discountPercent.toStringAsFixed(0)}% off')
        : null;
    final path = branchId != null
        ? '${AppRoutes.productDetail('${product['id']}')}?branch_id=$branchId'
        : AppRoutes.productDetail('${product['id']}');

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.card,
      child: InkWell(
        onTap: () => context.push(path, extra: product),
        borderRadius: AppBorders.card,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppBorders.card,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: AppBorders.md,
                  child: SizedBox(
                    width: 76.w,
                    height: 76.w,
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
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        hasDiscount && discountLabel != null
                            ? '$price · $discountLabel'
                            : price,
                        style: tt.bodyMedium?.copyWith(
                          color: hasDiscount
                              ? context.appColors.deal
                              : cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'View details',
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
