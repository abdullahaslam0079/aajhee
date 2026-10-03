part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _StoreHero extends StatelessWidget {
  const _StoreHero({
    required this.businessName,
    required this.branchName,
    required this.logoUrl,
    required this.isVerified,
    required this.isFavorite,
    required this.canFavorite,
    required this.onFavoriteTap,
    required this.address,
    this.ratingAvg,
    this.ratingCount = 0,
    this.categoryName,
    this.distanceKm,
  });

  final String businessName;
  final String branchName;
  final String? logoUrl;
  final String? ratingAvg;
  final int ratingCount;
  final bool isVerified;
  final String? categoryName;
  final double? distanceKm;
  final String address;
  final bool isFavorite;
  final bool canFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final appColors = context.appColors;

    final category = categoryName?.trim() ?? '';
    final distanceLabel = distanceKm != null
        ? GeoDistanceUtils.formatDistanceLabel(distanceKm!)
        : null;
    final metaParts = <String>[
      if (category.isNotEmpty) category,
      if (distanceLabel != null) distanceLabel,
    ];
    final hasRating = ratingCount > 0;
    final hasAddress = address.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StoreLogoBadge(
              name: businessName,
              imageUrl: logoUrl,
              size: 44,
              borderRadius: AppBorders.sm,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          businessName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            letterSpacing: -0.3,
                            height: 1.15,
                          ),
                        ),
                      ),
                      if (isVerified) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: cs.primary,
                        ),
                      ],
                    ],
                  ),
                  if (branchName.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      branchName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (canFavorite)
              IconButton(
                onPressed: onFavoriteTap,
                tooltip: isFavorite ? 'Remove from saved' : 'Save shop',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.all(6.w),
                constraints: BoxConstraints.tightFor(
                  width: 34.w,
                  height: 34.w,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isFavorite
                      ? appColors.favorite.withValues(alpha: 0.12)
                      : cs.surfaceContainerHigh.withValues(alpha: 0.7),
                  foregroundColor: isFavorite
                      ? appColors.favorite
                      : cs.onSurfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorders.iconButton,
                  ),
                ),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                ),
              ),
          ],
        ),
        if (metaParts.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Text(
            metaParts.join('  ·  '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
        if (hasRating) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: 15,
                color: const Color(0xFFE6A817),
              ),
              SizedBox(width: 4.w),
              Text(
                ratingAvg ?? '0.0',
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  height: 1.1,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '($ratingCount)',
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
        if (hasAddress) ...[
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: AppBorders.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: cs.primary,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    address,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
