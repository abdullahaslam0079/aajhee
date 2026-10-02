part of 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';

class _SearchProductTile extends StatelessWidget {
  const _SearchProductTile({
    required this.product,
    required this.onTap,
  });

  final CommerceProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasDiscount = product.hasDiscount;
    final imageUrl = product.imageUrl;
    final price = formatRs(product.effectivePrice ?? product.basePrice);
    final discountPercent = product.effectiveDiscountPercent;

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
                      product.displayName,
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
