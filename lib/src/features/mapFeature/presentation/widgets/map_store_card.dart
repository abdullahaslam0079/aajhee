import 'dart:math' as math;

import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class MapStoreCard extends ConsumerWidget {
  const MapStoreCard({
    super.key,
    required this.branch,
    required this.isSelected,
    required this.onTap,
    required this.onViewDetails,
  });

  final MapBranchModel branch;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final appColors = context.appColors;
    final isDark = context.theme.brightness == Brightness.dark;
    final muted = isDark
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface.withValues(alpha: 0.55);
    final discountPercent = branch.highestDiscountPercent.round();
    final distanceKm = _distanceKm(ref);
    final metaLabel = branch.categoryName.isNotEmpty
        ? '${branch.categoryName} • ${distanceKm.toStringAsFixed(1)} km'
        : '${distanceKm.toStringAsFixed(1)} km away';

    final cardColor =
        isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface;
    final footerColor = isDark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainerLow;

    return AnimatedScale(
      scale: isSelected ? 1 : 0.97,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: MapConstants.storeCardHeight,
        width: MapConstants.storeCardWidth,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: AppBorders.card,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: isDark ? 0.45 : 0.28),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.16),
              blurRadius: isDark ? 24 : 16,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppBorders.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Material(
                  color: colorScheme.surfaceContainerHighest,
                  child: InkWell(
                    onTap: onTap,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NetworkImageWithFallback(
                          primaryUrl: branch.coverImageUrl,
                          debugLabel: 'map cover ${branch.displayName}',
                          fit: BoxFit.cover,
                          errorWidget: ColoredBox(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.storefront_outlined,
                              color: colorScheme.onSurfaceVariant,
                              size: 32,
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.18),
                                Colors.black.withValues(alpha: 0.02),
                                Colors.black.withValues(alpha: 0.34),
                              ],
                              stops: const [0, 0.45, 1],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          top: 10,
                          child: Row(
                            children: [
                              if (branch.categoryName.isNotEmpty)
                                Flexible(
                                  child: _Badge(
                                    label: branch.categoryName,
                                    background: Colors.black.withValues(
                                      alpha: 0.62,
                                    ),
                                    foreground: Colors.white,
                                  ),
                                ),
                              if (branch.categoryName.isNotEmpty &&
                                  discountPercent > 0)
                                const SizedBox(width: 6),
                              if (discountPercent > 0)
                                _Badge(
                                  label: '$discountPercent% off',
                                  background: appColors.deal,
                                  foreground: appColors.onDeal,
                                  icon: Icons.local_offer_rounded,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: footerColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: onTap,
                          borderRadius: AppBorders.md,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                metaLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                  color: muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                branch.formattedAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.9),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onViewDetails,
                          borderRadius: AppBorders.button,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: AppBorders.button,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Details',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: colorScheme.onPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppBorders.md,
        boxShadow: AppShadows.subtle,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: foreground),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
