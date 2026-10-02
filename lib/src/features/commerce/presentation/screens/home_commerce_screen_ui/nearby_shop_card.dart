part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _NearbyShopCard extends StatelessWidget {
  const _NearbyShopCard({
    required this.branch,
    required this.onTap,
    required this.imageHeight,
    required this.imageWidth,
    required this.padding,
  });

  final MapBranchModel branch;
  final VoidCallback onTap;
  final double imageHeight;
  final double imageWidth;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final badge = branch.deliveryBadgeLabel;
    final distance = branch.distanceKm;
    final category = branch.categoryName.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Ink(
          width: 252.w,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppBorders.card,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.65),
            ),
            boxShadow: AppShadows.subtle,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StoreLogoBadge(
                name: branch.displayName,
                imageUrl: branch.logoUrl,
                size: imageHeight,
                width: imageWidth,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      branch.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        if (distance != null) ...[
                          Icon(
                            Icons.near_me_outlined,
                            size: 12,
                            color: cs.onSurfaceVariant,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            '${distance.toStringAsFixed(1)} km',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                              fontSize: 11,
                            ),
                          ),
                          if (badge != null) SizedBox(width: 6.w),
                        ],
                        if (badge != null)
                          Flexible(
                            fit: FlexFit.loose,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: _SameDayDeliveryChip(label: badge),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.onSurfaceVariant.withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
