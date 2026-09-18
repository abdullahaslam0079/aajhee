import 'package:aajhee/src/features/home/data/models/offer_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

/// Horizontal deal row for offer list feeds.
class OfferListCard extends ConsumerWidget {
  const OfferListCard({
    super.key,
    required this.offer,
    required this.onTap,
  });

  final OfferModel offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final appColors = context.appColors;
    final muted = cs.onSurfaceVariant;
    final imageUrls = offer.displayImageUrls;
    final logoUrl = offer.businessLogoUrl ??
        ref.watch(
          homeFeedProvider.select(
            (state) => state.logoUrlForBusiness(offer.businessId),
          ),
        );
    final address = (offer.featuredBranchAddress?.trim().isNotEmpty ?? false)
        ? offer.featuredBranchAddress!.trim()
        : ref.watch(
            homeFeedProvider.select(
              (state) => state.addressForOffer(
                featuredBranchId: offer.featuredBranchId,
                businessId: offer.businessId,
              ),
            ),
          );
    final distance = offer.isAvailableInStore && offer.nearestDistanceKm != null
        ? GeoDistanceUtils.formatDistanceLabel(offer.nearestDistanceKm!)
        : null;
    final hasPrice = offer.discountedPrice != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Ink(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppBorders.card,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OfferThumbnail(
                  imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
                  businessName: offer.businessName,
                  badgeLabel: offer.promoBadgeLabel,
                  debugLabel: offer.title,
                  dealColor: appColors.deal,
                  onDealColor: appColors.onDeal,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                          children: [
                            StoreLogoBadge(
                              name: offer.businessName,
                              imageUrl: logoUrl,
                              size: 16,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                offer.businessName,
                                style: tt.labelSmall?.copyWith(
                                  color: muted,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          offer.title,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            letterSpacing: -0.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasPrice) ...[
                          SizedBox(height: 6.h),
                          _PriceRow(offer: offer),
                        ],
                        if (address != null || distance != null) ...[
                          SizedBox(height: 6.h),
                          _LocationLine(address: address, distance: distance),
                        ],
                        if (offer.isAvailableOnline ||
                            offer.isAvailableInStore) ...[
                          SizedBox(height: 8.h),
                          _ChannelChips(
                            showOnline: offer.isAvailableOnline,
                            showInStore: offer.isAvailableInStore,
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
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({
    this.address,
    this.distance,
  });

  final String? address;
  final String? distance;

  @override
  Widget build(BuildContext context) {
    final muted = context.theme.colorScheme.onSurfaceVariant;
    final tt = context.theme.textTheme;

    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 13, color: muted),
        SizedBox(width: 4.w),
        if (address != null && address!.isNotEmpty)
          Expanded(
            child: Text(
              address!,
              style: tt.labelSmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          const Spacer(),
        if (distance != null) ...[
          SizedBox(width: 6.w),
          Text(
            distance!,
            style: tt.labelSmall?.copyWith(
              color: context.theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _ChannelChips extends StatelessWidget {
  const _ChannelChips({
    required this.showOnline,
    required this.showInStore,
  });

  final bool showOnline;
  final bool showInStore;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: [
        if (showOnline)
          const _ChannelChip(
            icon: Icons.language_rounded,
            label: 'Online',
          ),
        if (showInStore)
          const _ChannelChip(
            icon: Icons.storefront_outlined,
            label: 'In-store',
          ),
      ],
    );
  }
}

class _ChannelChip extends StatelessWidget {
  const _ChannelChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: AppBorders.full,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSurfaceVariant),
          SizedBox(width: 4.w),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferThumbnail extends StatelessWidget {
  const _OfferThumbnail({
    required this.imageUrl,
    required this.businessName,
    required this.badgeLabel,
    required this.debugLabel,
    required this.dealColor,
    required this.onDealColor,
  });

  final String? imageUrl;
  final String businessName;
  final String? badgeLabel;
  final String debugLabel;
  final Color dealColor;
  final Color onDealColor;

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final cs = context.theme.colorScheme;
    final size = 104.r;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppBorders.md,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: AppBorders.md,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null)
                NetworkImageWithFallback(
                  primaryUrl: imageUrl,
                  debugLabel: debugLabel,
                  fit: BoxFit.cover,
                  errorWidget: _ImagePlaceholder(businessName: businessName),
                )
              else
                _ImagePlaceholder(businessName: businessName),
              if (badgeLabel != null)
                Positioned(
                  left: 6.w,
                  top: 6.h,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: dealColor,
                      borderRadius: AppBorders.full,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      badgeLabel!,
                      style: tt.labelSmall?.copyWith(
                        color: onDealColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.businessName});

  final String businessName;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final initial = businessName.isNotEmpty
        ? businessName.substring(0, 1).toUpperCase()
        : '?';

    return ColoredBox(
      color: cs.surfaceContainerHigh,
      child: Center(
        child: Text(
          initial,
          style: context.theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.offer});

  final OfferModel offer;

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final muted = context.theme.colorScheme.onSurfaceVariant;
    final appColors = context.appColors;
    final original = offer.originalPrice;
    final discounted = offer.discountedPrice;

    if (discounted == null) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          discounted.asEuro,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: appColors.deal,
            letterSpacing: -0.2,
          ),
        ),
        if (original != null) ...[
          SizedBox(width: 6.w),
          Text(
            original.asEuro,
            style: tt.labelSmall?.copyWith(
              color: muted,
              decoration: TextDecoration.lineThrough,
              decorationColor: muted,
            ),
          ),
        ],
      ],
    );
  }
}
