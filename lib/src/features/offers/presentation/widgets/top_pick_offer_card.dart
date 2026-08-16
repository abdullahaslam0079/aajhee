import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

/// Compact portrait card for horizontal Top picks carousels.
class TopPickOfferCard extends StatelessWidget {
  const TopPickOfferCard({
    super.key,
    required this.offer,
    required this.onTap,
    this.width,
  });

  final OfferModel offer;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final appColors = context.appColors;
    final isDark = cs.brightness == Brightness.dark;
    final canvas = homeCanvasOf(context);
    final muted = cs.onSurface.withValues(alpha: 0.55);
    final imageUrls = offer.displayImageUrls;
    final cardWidth = width ?? 156.w;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Ink(
          width: cardWidth,
          decoration: BoxDecoration(
            color: canvas,
            borderRadius: AppBorders.card,
            border: Border.all(
              color: cs.onSurface.withValues(alpha: isDark ? 0.28 : 0.14),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppBorders.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 112.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrls.isNotEmpty)
                        NetworkImageWithFallback(
                          primaryUrl: imageUrls.first,
                          debugLabel: offer.title,
                          fit: BoxFit.cover,
                          errorWidget: _Placeholder(
                            businessName: offer.businessName,
                            dealColor: appColors.deal,
                          ),
                        )
                      else
                        _Placeholder(
                          businessName: offer.businessName,
                          dealColor: appColors.deal,
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              cs.scrim.withValues(alpha: 0.05),
                              Colors.transparent,
                              cs.scrim.withValues(alpha: 0.28),
                            ],
                          ),
                        ),
                      ),
                      if (offer.discountPercent > 0)
                        Positioned(
                          left: 8.w,
                          top: 8.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: appColors.deal,
                              borderRadius: AppBorders.full,
                            ),
                            child: Text(
                              '${offer.discountPercent.toStringAsFixed(0)}% OFF',
                              style: tt.labelSmall?.copyWith(
                                color: appColors.onDeal,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        right: 8.w,
                        top: 8.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: cs.scrim.withValues(alpha: 0.55),
                            borderRadius: AppBorders.full,
                          ),
                          child: Text(
                            offer.channelLabel,
                            style: tt.labelSmall?.copyWith(
                              color: cs.surfaceContainerLowest,
                              fontWeight: FontWeight.w700,
                              fontSize: 9.5,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: canvas,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.businessName,
                            style: tt.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            offer.title,
                            style: tt.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          if (offer.discountedPrice != null)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  offer.discountedPrice!.asEuro,
                                  style: tt.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: appColors.deal,
                                  ),
                                ),
                                if (offer.originalPrice != null) ...[
                                  SizedBox(width: 5.w),
                                  Flexible(
                                    child: Text(
                                      offer.originalPrice!.asEuro,
                                      style: tt.labelSmall?.copyWith(
                                        color: muted,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: muted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            )
                          else if (offer.discountPercent > 0)
                            Text(
                              'Save ${offer.discountPercent.toStringAsFixed(0)}%',
                              style: tt.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: appColors.deal,
                              ),
                            ),
                        ],
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
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
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
