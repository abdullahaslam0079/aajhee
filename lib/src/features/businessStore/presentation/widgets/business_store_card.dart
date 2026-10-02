import 'dart:math' as math;

import 'package:aajhee/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:aajhee/src/features/home/data/models/branch_top_product_model.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/utils/money_format.dart';

part 'business_store_card_ui/rating_category_row.dart';
part 'business_store_card_ui/distance_delivery_row.dart';
part 'business_store_card_ui/product_preview_row.dart';
part 'business_store_card_ui/product_preview_tile.dart';
part 'business_store_card_ui/view_all_products_button.dart';


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
    final muted = cs.onSurfaceVariant;
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
    final deliveryLabel = branch.deliveryBadgeLabel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.xl,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppBorders.xl,
            color: AppBrandColors.surface,
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.28),
            ),
            boxShadow: AppShadows.subtle,
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
                      size: 48,
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
                              letterSpacing: -0.25,
                              height: 1.25,
                              fontSize: 15.sp,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5.h),
                          _RatingCategoryRow(
                            showRating: showRating,
                            ratingAvg: ratingAvg,
                            ratingCount: ratingCount,
                            category: category,
                            muted: muted,
                            textTheme: tt,
                          ),
                          SizedBox(height: 6.h),
                          _DistanceDeliveryRow(
                            distanceLabel: distanceLabel,
                            deliveryLabel: deliveryLabel,
                            muted: muted,
                            textTheme: tt,
                            colorScheme: cs,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4.w),
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
                          padding: EdgeInsets.all(4.w),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? appColors.favorite
                                : cs.onSurface.withValues(alpha: 0.32),
                            size: 20,
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
                SizedBox(height: 10.h),
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

