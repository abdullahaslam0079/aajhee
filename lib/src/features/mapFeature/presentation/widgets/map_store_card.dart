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
    final muted = colorScheme.onSurface.withValues(alpha: 0.55);
    final discountPercent = branch.highestDiscountPercent.round();
    final distanceKm = _distanceKm(ref);
    final metaLabel = branch.categoryName.isNotEmpty
        ? '${branch.categoryName} • ${distanceKm.toStringAsFixed(1)} km'
        : '${distanceKm.toStringAsFixed(1)} km away';

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
          color: colorScheme.surface,
          borderRadius: AppBorders.xl,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.7),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.elevated : AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: AppBorders.xl,
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
                              Icons.fastfood_outlined,
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
                                Colors.black.withValues(alpha: 0.12),
                                Colors.black.withValues(alpha: 0.02),
                                Colors.black.withValues(alpha: 0.28),
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
                                _Badge(
                                  label: branch.categoryName,
                                  background:
                                      Colors.black.withValues(alpha: 0.72),
                                  foreground: Colors.white,
                                ),
                              const Spacer(),
                              if (discountPercent > 0)
                                _Badge(
                                  label: '$discountPercent% off',
                                  background: appColors.warning,
                                  foreground: appColors.onWarning,
                                  icon: Icons.local_offer_rounded,
                                ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.subtle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.near_me_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
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
                              const SizedBox(height: 2),
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
                                  color: colorScheme.onSurfaceVariant,
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
                          borderRadius: AppBorders.full,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: AppBorders.full,
                              border: Border.all(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Details',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: colorScheme.onPrimaryContainer,
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
        borderRadius: AppBorders.full,
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
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
