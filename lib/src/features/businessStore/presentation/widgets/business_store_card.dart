import 'dart:math' as math;

import 'package:aajhee/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/utils/money_format.dart';

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
    final isDark = context.theme.brightness == Brightness.dark;
    final muted = isDark
        ? cs.onSurfaceVariant
        : cs.onSurface.withValues(alpha: 0.55);
    final isFavorite = ref.watch(
      favoriteStoresProvider.select(
        (state) => state.isFavorite(branch.id),
      ),
    );
    final distanceKm = branch.distanceKm ?? _distanceKm(ref);
    final distanceLabel = '${distanceKm.toStringAsFixed(1)} km';
    final category = branch.categoryName.trim();
    final deliveryBadge = branch.deliveryBadgeLabel;
    final ratingAvg = branch.ratingAvg;
    final ratingCount = branch.ratingCount;
    final showRating = ratingAvg != null &&
        (ratingCount == null || ratingCount > 0);
    final deliveryFee = branch.deliveryFee;
    final isOpen = branch.isOpen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppBorders.card,
            color: isDark ? cs.surfaceContainer : cs.surfaceContainerHighest,
            boxShadow: AppShadows.subtle,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StoreLogoBadge(
                  name: branch.displayName,
                  imageUrl: branch.logoUrl,
                  size: 52,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              branch.displayName,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                height: 1.15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (showRating) ...[
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: appColors.deal,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              ratingAvg.toStringAsFixed(1),
                              style: tt.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            if (ratingCount != null && ratingCount > 0)
                              Text(
                                ' ($ratingCount)',
                                style: tt.labelSmall?.copyWith(
                                  color: muted,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                ),
                              ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          if (category.isNotEmpty)
                            Flexible(
                              child: Text(
                                category,
                                style: tt.labelSmall?.copyWith(
                                  color: muted,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (category.isNotEmpty && deliveryBadge != null)
                            Text(
                              ' · ',
                              style: tt.labelSmall?.copyWith(color: muted),
                            ),
                          if (deliveryBadge != null)
                            Text(
                              deliveryBadge,
                              style: tt.labelSmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.near_me_rounded,
                            size: 12,
                            color: muted,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            distanceLabel,
                            style: tt.labelSmall?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                            ),
                          ),
                          if (deliveryFee != null) ...[
                            Text(
                              ' · ',
                              style: tt.labelSmall?.copyWith(color: muted),
                            ),
                            Text(
                              formatRs(deliveryFee),
                              style: tt.labelSmall?.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                          ],
                          if (isOpen != null) ...[
                            Text(
                              ' · ',
                              style: tt.labelSmall?.copyWith(color: muted),
                            ),
                            Text(
                              isOpen ? 'Open' : 'Closed',
                              style: tt.labelSmall?.copyWith(
                                color: isOpen
                                    ? cs.primary
                                    : cs.error.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: AppBorders.iconButton,
                    onTap: () => ref.read(favoriteStoresProvider.notifier).toggle(
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
                            : cs.onSurface.withValues(alpha: 0.45),
                        size: 22,
                      ),
                    ),
                  ),
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
