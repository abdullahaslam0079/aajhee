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
    final distanceKm = branch.distanceKm ?? _distanceKm(ref);
    final distanceLabel = '${distanceKm.toStringAsFixed(1)} km';
    final category = branch.categoryName.trim();
    final address = branch.formattedAddress.trim();
    final branchLabel = branch.name.trim();
    final showBranchLabel = branchLabel.isNotEmpty &&
        branchLabel.toLowerCase() != branch.displayName.toLowerCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.xl,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppBorders.xl,
            color: cs.surfaceContainerHighest,
            boxShadow: AppShadows.subtle,
          ),
          child: ClipRRect(
            borderRadius: AppBorders.xl,
            child: SizedBox(
              height: 204.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageWithFallback(
                    primaryUrl: branch.coverImageUrl,
                    debugLabel: 'cover ${branch.displayName}',
                    fit: BoxFit.cover,
                    errorWidget: ColoredBox(
                      color: cs.surfaceContainerHighest,
                      child: Icon(
                        Icons.storefront_outlined,
                        color: muted,
                        size: 36,
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x14000000),
                          Color(0x00000000),
                          Color(0x59000000),
                        ],
                        stops: [0, 0.42, 1],
                      ),
                    ),
                  ),
                  if (branch.highestDiscountPercent > 0)
                    Positioned(
                      left: 12.w,
                      top: 12.h,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: appColors.warning,
                          borderRadius: AppBorders.full,
                          boxShadow: AppShadows.subtle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 5.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer_rounded,
                                size: 13,
                                color: appColors.onWarning,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${branch.highestDiscountPercent.toStringAsFixed(0)}% Off',
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: appColors.onWarning,
                                  height: 1,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 12.w,
                    top: 12.h,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => ref
                            .read(favoriteStoresProvider.notifier)
                            .toggle(
                              branchId,
                              businessId: branch.businessId,
                            ),
                        child: Ink(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.surfaceContainerLowest
                                .withValues(alpha: 0.95),
                            boxShadow: AppShadows.subtle,
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? cs.error
                                : cs.onSurface.withValues(alpha: 0.72),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10.w,
                    right: 10.w,
                    bottom: 10.h,
                    child: ClipRRect(
                      borderRadius: AppBorders.lg,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLowest
                                .withValues(alpha: 0.92),
                            borderRadius: AppBorders.lg,
                            border: Border.all(
                              color: cs.surfaceContainerLowest,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              10.w,
                              10.h,
                              8.w,
                              10.h,
                            ),
                            child: Row(
                              children: [
                                StoreLogoBadge(
                                  name: branch.displayName,
                                  imageUrl: branch.logoUrl,
                                  size: 44,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        branch.displayName,
                                        style: tt.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                          height: 1.15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (showBranchLabel) ...[
                                        SizedBox(height: 2.h),
                                        Text(
                                          branchLabel,
                                          style: tt.labelSmall?.copyWith(
                                            color: muted,
                                            fontWeight: FontWeight.w600,
                                            height: 1.15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      SizedBox(height: 5.h),
                                      Row(
                                        children: [
                                          _MetaChip(
                                            icon: Icons.near_me_rounded,
                                            label: distanceLabel,
                                            foreground: cs.primary,
                                            background: cs.primary
                                                .withValues(alpha: 0.1),
                                          ),
                                          if (category.isNotEmpty) ...[
                                            SizedBox(width: 6.w),
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
                                          ],
                                        ],
                                      ),
                                      if (address.isNotEmpty) ...[
                                        SizedBox(height: 4.h),
                                        Text(
                                          address,
                                          style: tt.labelSmall?.copyWith(
                                            color: muted.withValues(
                                              alpha: 0.85,
                                            ),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10.5,
                                            height: 1.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 22,
                                  color: cs.onSurface.withValues(alpha: 0.35),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppBorders.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          SizedBox(width: 3.w),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              height: 1.1,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
