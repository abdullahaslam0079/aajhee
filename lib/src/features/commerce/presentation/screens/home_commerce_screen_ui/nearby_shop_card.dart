part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _NearbyShopCard extends StatelessWidget {
  const _NearbyShopCard({
    required this.branch,
    required this.onTap,
  });

  final MapBranchModel branch;
  final VoidCallback onTap;

  static const int _previewLimit = 4;
  static const double _thumbSize = 44;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final badge = branch.deliveryBadgeLabel;
    final distance = branch.distanceKm;
    final category = branch.categoryName.trim();
    final metaParts = <String>[
      if (category.isNotEmpty) category,
      if (distance != null) '${distance.toStringAsFixed(1)} km',
      if (badge != null) badge,
    ];
    final previews =
        branch.topProducts.take(_previewLimit).toList(growable: false);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Ink(
          width: 220.w,
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppBorders.card,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  StoreLogoBadge(
                    name: branch.displayName,
                    imageUrl: branch.logoUrl,
                    size: 36,
                    borderRadius: AppBorders.sm,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.15,
                            fontSize: 12.sp,
                          ),
                        ),
                        if (metaParts.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            metaParts.join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              height: 1.15,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                  ),
                ],
              ),
              if (previews.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    for (var i = 0; i < previews.length; i++) ...[
                      if (i > 0) SizedBox(width: 5.w),
                      _HomeShopProductThumb(product: previews[i]),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeShopProductThumb extends StatelessWidget {
  const _HomeShopProductThumb({required this.product});

  final BranchTopProductModel product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = _NearbyShopCard._thumbSize.w;
    final url = product.imageUrl;

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: AppBorders.sm,
        ),
        child: ClipRRect(
          borderRadius: AppBorders.sm,
          child: url != null && url.isNotEmpty
              ? CommonImage(
                  imageUrl: url,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  borderRadius: AppBorders.sm,
                )
              : Icon(
                  Icons.image_outlined,
                  size: 15,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                ),
        ),
      ),
    );
  }
}
