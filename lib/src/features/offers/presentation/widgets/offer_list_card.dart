import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

/// Horizontal deal row for offer list feeds.
class OfferListCard extends StatelessWidget {
  const OfferListCard({
    super.key,
    required this.offer,
    required this.onTap,
  });

  final OfferModel offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final appColors = context.appColors;
    final muted = cs.onSurface.withValues(alpha: 0.52);
    final imageUrls = offer.displayImageUrls;
    final hasGallery = imageUrls.length > 1;
    final category = offer.categoryName.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Ink(
          decoration: BoxDecoration(
            color: homeCanvasOf(context),
            borderRadius: AppBorders.card,
            border: Border.all(
              color: cs.onSurface.withValues(alpha: 0.14),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OfferThumbnail(
                    imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
                    businessName: offer.businessName,
                    discountPercent: offer.discountPercent,
                    galleryCount: hasGallery ? imageUrls.length : null,
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
                              imageUrl: offer.businessLogoUrl,
                              size: 20,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                offer.businessName,
                                style: tt.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          offer.title,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _metaLine(
                            category,
                            offer.nearestDistanceKm,
                            channelLabel: offer.channelLabel,
                          ),
                          style: tt.labelSmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        SizedBox(height: 6.h),
                        _PriceRow(offer: offer),
                        if (offer.summaryText.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          Text(
                            offer.summaryText,
                            style: tt.labelSmall?.copyWith(
                              color: muted,
                              height: 1.2,
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
    );
  }
}

String _metaLine(
  String category,
  double? nearestDistanceKm, {
  required String channelLabel,
}) {
  final parts = <String>[channelLabel];
  if (category.isNotEmpty) parts.add(category);
  if (nearestDistanceKm != null && channelLabel != 'Online') {
    parts.add(GeoDistanceUtils.formatDistanceLabel(nearestDistanceKm));
  }
  return parts.join(' · ');
}

class _OfferThumbnail extends StatelessWidget {
  const _OfferThumbnail({
    required this.imageUrl,
    required this.businessName,
    required this.discountPercent,
    required this.debugLabel,
    required this.dealColor,
    required this.onDealColor,
    this.galleryCount,
  });

  final String? imageUrl;
  final String businessName;
  final double discountPercent;
  final String debugLabel;
  final Color dealColor;
  final Color onDealColor;
  final int? galleryCount;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final size = 108.r;

    return ClipRRect(
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
                errorWidget: _ImagePlaceholder(
                  businessName: businessName,
                  dealColor: dealColor,
                ),
              )
            else
              _ImagePlaceholder(
                businessName: businessName,
                dealColor: dealColor,
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.scrim.withValues(alpha: 0.08),
                    Colors.transparent,
                    cs.scrim.withValues(alpha: 0.16),
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
            if (discountPercent > 0)
              Positioned(
                left: 6.w,
                top: 6.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: dealColor,
                    borderRadius: AppBorders.full,
                  ),
                  child: Text(
                    '${discountPercent.toStringAsFixed(0)}% OFF',
                    style: tt.labelSmall?.copyWith(
                      color: onDealColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      height: 1,
                    ),
                  ),
                ),
              ),
            if (galleryCount != null)
              Positioned(
                right: 6.w,
                bottom: 6.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: cs.scrim.withValues(alpha: 0.55),
                    borderRadius: AppBorders.full,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library_rounded,
                        size: 11,
                        color: cs.surfaceContainerLowest.withValues(alpha: 0.95),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '$galleryCount',
                        style: tt.labelSmall?.copyWith(
                          color: cs.surfaceContainerLowest,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.businessName,
    required this.dealColor,
  });

  final String businessName;
  final Color dealColor;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final initial = businessName.isNotEmpty
        ? businessName.substring(0, 1).toUpperCase()
        : '?';

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.95),
            dealColor.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: context.theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.primary,
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
    final cs = context.theme.colorScheme;
    final appColors = context.appColors;
    final muted = cs.onSurface.withValues(alpha: 0.38);
    final original = offer.originalPrice;
    final discounted = offer.discountedPrice;

    if (original != null && discounted != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            discounted.asEuro,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: appColors.deal,
            ),
          ),
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
      );
    }

    if (offer.discountPercent > 0) {
      return Text(
        'Save ${offer.discountPercent.toStringAsFixed(0)}%',
        style: tt.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: appColors.onDealContainer ?? appColors.deal,
        ),
      );
    }

    return Text(
      'Special price',
      style: tt.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}
