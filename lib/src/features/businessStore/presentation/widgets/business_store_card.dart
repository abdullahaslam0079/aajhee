import 'dart:math' as math;
import 'dart:ui';

import 'package:goluto/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

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
    final branchId = branch.id.toString();
    final isFavorite = ref.watch(
      favoriteStoresProvider.select((state) => state.isFavorite(branchId)),
    );
    final distanceKm = _distanceKm(ref);
    final topOffer = branch.highestDiscountOffer;
    final offerTitle = topOffer?.title.trim() ?? '';
    final offerDescription = topOffer?.description.trim() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.xl,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: AppBorders.xl,
          ),
          child: ClipRRect(
            borderRadius: AppBorders.xl,
            child: SizedBox(
              height: 180.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageWithFallback(
                    primaryUrl: branch.coverImageUrl,
                    debugLabel: 'cover ${branch.displayName}',
                    fit: BoxFit.contain,
                    errorWidget: ColoredBox(
                      color: cs.surfaceContainerHighest,
                      child: Icon(
                        Icons.fastfood_outlined,
                        color: muted,
                        size: 34,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: AppBorders.xl,
                      border: Border.all(
                        color: cs.scrim.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          cs.surfaceContainerLowest.withValues(alpha: 0),
                          cs.scrim.withValues(alpha: 0.25),
                        ],
                        stops: const [0.45, 1.0],
                      ),
                    ),
                  ),
                  if (branch.highestDiscountPercent > 0)
                    Positioned(
                      left: AppSpacing.ms.w,
                      top: AppSpacing.ms.h,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: appColors.warning,
                          borderRadius: AppBorders.full,
                          boxShadow: AppShadows.subtle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 5.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer_rounded,
                                size: 14,
                                color: appColors.onWarning,
                              ),
                              SizedBox(width: AppSpacing.xxs.w),
                              Text(
                                'Flat ${branch.highestDiscountPercent.toStringAsFixed(0)}% Off',
                                style: tt.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: appColors.onWarning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Favorite button
                  Positioned(
                    right: AppSpacing.ms.w,
                    top: AppSpacing.ms.h,
                    child: GestureDetector(
                      onTap: () => ref
                          .read(favoriteStoresProvider.notifier)
                          .toggle(branchId),
                      behavior: HitTestBehavior.opaque,
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.surfaceContainerLowest
                                  .withValues(alpha: 0.22),
                              border: Border.all(
                                color: cs.surfaceContainerLowest
                                    .withValues(alpha: 0.55),
                                width: 1.2,
                              ),
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? cs.error
                                  : cs.surfaceContainerLowest,
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Business store card content
                  Positioned(
                    left: AppSpacing.ms.w,
                    right: AppSpacing.ms.w,
                    bottom: AppSpacing.ms.h,
                    child: ClipRRect(
                      borderRadius: AppBorders.lg,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLowest
                                .withValues(alpha: 0.78),
                            borderRadius: AppBorders.lg,
                            border: Border.all(
                              color: cs.surfaceContainerLowest
                                  .withValues(alpha: 0.85),
                            ),
                            boxShadow: AppShadows.card,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.sm.r),
                            child: Row(
                              children: [
                                StoreLogoBadge(
                                  name: branch.displayName,
                                  imageUrl: branch.logoUrl,
                                  size: 48,
                                ),
                                SizedBox(width: AppSpacing.sm.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        branch.displayName,
                                        style: tt.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        '${branch.categoryName} \u2022 ${distanceKm.toStringAsFixed(2)} km',
                                        style: tt.bodyMedium?.copyWith(
                                          color: muted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (offerTitle.isNotEmpty) ...[
                                        SizedBox(height: 4.h),
                                        Text(
                                          offerTitle,
                                          style: tt.labelLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
