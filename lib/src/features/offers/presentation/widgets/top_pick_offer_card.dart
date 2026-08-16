import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

/// Compact portrait card for horizontal Top picks carousels.
class TopPickOfferCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final appColors = context.appColors;
    final isDark = cs.brightness == Brightness.dark;
    final canvas = homeCanvasOf(context);
    final muted = cs.onSurface.withValues(alpha: 0.55);
    final imageUrls = offer.displayImageUrls;
    final cardWidth = width ?? 156.w;
    final logoUrl = offer.businessLogoUrl ??
        ref.watch(
          homeFeedProvider.select(
            (state) => state.logoUrlForBusiness(offer.businessId),
          ),
        );

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
                      if (offer.promoBadgeLabel != null)
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
                              offer.promoBadgeLabel!,
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
                        child: _ChannelBadge(offer: offer),
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
                          Row(
                            children: [
                              StoreLogoBadge(
                                name: offer.businessName,
                                imageUrl: logoUrl,
                                size: 16,
                              ),
                              SizedBox(width: 5.w),
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
                            )
                          else if (offer.isDealOffer)
                            Text(
                              'Deal',
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

class _ChannelBadge extends StatelessWidget {
  const _ChannelBadge({required this.offer});

  final OfferModel offer;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tt = context.theme.textTheme;
    final icons = <IconData>[
      if (offer.isAvailableOnline) Icons.language_rounded,
      if (offer.isAvailableInStore) Icons.storefront_outlined,
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: isDark ? 0.78 : 0.56),
        borderRadius: AppBorders.full,
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.42 : 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < icons.length; i++) ...[
            if (i > 0) SizedBox(width: 3.w),
            Icon(icons[i], size: 11, color: Colors.white),
          ],
          if (!offer.isHybridChannel) ...[
            SizedBox(width: 3.w),
            Text(
              offer.channelShortLabel,
              style: tt.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 9.5,
                height: 1,
              ),
            ),
          ],
        ],
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
