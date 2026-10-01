import 'dart:math' as math;

import 'package:aajhee/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:aajhee/src/features/home/data/models/branch_top_product_model.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class BusinessStoreCard extends ConsumerWidget {
  const BusinessStoreCard({
    super.key,
    required this.branch,
    this.onTap,
  });

  final MapBranchModel branch;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final appColors = context.appColors;
    final muted = cs.onSurface.withValues(alpha: 0.55);
    final isFavorite = ref.watch(
      favoriteStoresProvider.select(
        (state) => state.isFavorite(branch.id),
      ),
    );
    final distanceKm = branch.distanceKm ?? _distanceKm(ref);
    final distanceLabel = '${distanceKm.toStringAsFixed(1)} km';
    final category = branch.categoryName.trim();
    final ratingAvg = branch.ratingAvg;
    final ratingCount = branch.ratingCount;
    final showRating =
        ratingAvg != null && (ratingCount == null || ratingCount > 0);
    final previewProducts = branch.topProducts.take(8).toList(growable: false);
    final productsCount = branch.productsCount;
    final ctaLabel = productsCount > 0
        ? 'View all products ($productsCount)'
        : 'View all products';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.xl,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppBorders.xl,
            color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
            boxShadow: AppShadows.card,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 12.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StoreLogoBadge(
                      name: branch.displayName,
                      imageUrl: branch.logoUrl,
                      size: 52,
                      borderRadius: AppBorders.md,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.displayName,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (showRating) ...[
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 15,
                                  color: Color(0xFFF5B400),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  ratingAvg.toStringAsFixed(1),
                                  style: tt.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                                if (ratingCount != null && ratingCount > 0)
                                  Text(
                                    ' ($ratingCount)',
                                    style: tt.labelMedium?.copyWith(
                                      color: muted,
                                      fontWeight: FontWeight.w500,
                                      height: 1.1,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          if (category.isNotEmpty) ...[
                            SizedBox(height: 3.h),
                            Text(
                              category,
                              style: tt.labelMedium?.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: muted,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                distanceLabel,
                                style: tt.labelSmall?.copyWith(
                                  color: muted,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: AppBorders.full,
                        onTap: () =>
                            ref.read(favoriteStoresProvider.notifier).toggle(
                                  branch.id,
                                  branch: branch,
                                ),
                        child: Padding(
                          padding: EdgeInsets.all(6.w),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? appColors.favorite
                                : cs.onSurface.withValues(alpha: 0.4),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (previewProducts.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _ProductPreviewRow(
                    products: previewProducts,
                    onMoreTap: onTap,
                  ),
                ],
                SizedBox(height: 12.h),
                _ViewAllProductsButton(
                  label: ctaLabel,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _distanceKm(WidgetRef ref) {
    final savedAddress = ref.watch(savedAddressesProvider).selectedAddress;
    final userLat = savedAddress?.latitude;
    final userLng = savedAddress?.longitude;

    if (userLat != null && userLng != null) {
      return _haversineKm(userLat, userLng, branch.latitude, branch.longitude);
    }

    return _haversineKm(52.52, 13.405, branch.latitude, branch.longitude);
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}

class _ProductPreviewRow extends StatelessWidget {
  const _ProductPreviewRow({
    required this.products,
    this.onMoreTap,
  });

  final List<BranchTopProductModel> products;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final thumbSize = 64.w;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: thumbSize,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final product = products[index];
                final url = product.imageUrl;
                return SizedBox(
                  width: thumbSize,
                  height: thumbSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.9),
                      borderRadius: AppBorders.md,
                    ),
                    child: ClipRRect(
                      borderRadius: AppBorders.md,
                      child: url != null && url.isNotEmpty
                          ? CommonImage(
                              imageUrl: url,
                              width: thumbSize,
                              height: thumbSize,
                              fit: BoxFit.cover,
                              borderRadius: AppBorders.md,
                            )
                          : ColoredBox(
                              color: cs.surfaceContainerHighest,
                              child: Icon(
                                Icons.image_outlined,
                                size: 22,
                                color: cs.onSurface.withValues(alpha: 0.35),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Material(
          color: cs.surface,
          shape: const CircleBorder(),
          elevation: 1.5,
          shadowColor: Colors.black26,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onMoreTap,
            child: SizedBox(
              width: 34.w,
              height: 34.w,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewAllProductsButton extends StatelessWidget {
  const _ViewAllProductsButton({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Material(
      color: cs.primaryContainer.withValues(alpha: 0.55),
      borderRadius: AppBorders.full,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.full,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 18,
                color: cs.primary,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  style: tt.labelLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: cs.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
