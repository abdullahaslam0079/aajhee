import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class DiscountOfferCard extends StatelessWidget {
  const DiscountOfferCard({
    super.key,
    required this.offer,
    required this.onTap,
    required this.onToggleOfferLike,
    required this.onToggleBusinessLike,
  });

  final OfferModel offer;
  final VoidCallback onTap;
  final VoidCallback onToggleOfferLike;
  final VoidCallback onToggleBusinessLike;

  static const Color _discountColor = Color(0xFFFF9500);

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.62);
    final imageUrl =
        offer.imageUrl != null && offer.imageUrl!.isNotEmpty ? offer.imageUrl : null;
    final dealTypeLabel =
        offer.offerType == OfferType.item ? 'Item deal' : 'Flat off';

    return Material(
      color: Colors.transparent,
      borderRadius: AppBorders.lg,
      child: InkWell(
        borderRadius: AppBorders.lg,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppBorders.lg,
            border: Border.all(color: cs.outline.withValues(alpha: 0.28)),
            boxShadow: AppShadows.card,
          ),
          child: ClipRRect(
            borderRadius: AppBorders.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.ms.w,
                    vertical: AppSpacing.sm.h,
                  ),
                  color: cs.inverseSurface,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.businessName,
                              style: tt.labelLarge?.copyWith(
                                color: cs.onInverseSurface.withValues(alpha: 0.82),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              offer.title,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onInverseSurface,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onToggleBusinessLike,
                        icon: Icon(
                          offer.isBusinessLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: offer.isBusinessLiked
                              ? Colors.redAccent
                              : cs.onInverseSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.ms.r),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (offer.summaryText.isNotEmpty)
                              Text(
                                offer.summaryText,
                                style: tt.titleSmall?.copyWith(height: 1.3),
                              ),
                            if (offer.discountPercent > 0) ...[
                              SizedBox(height: AppSpacing.sm.h),
                              _TagChip(
                                label:
                                    '${offer.discountPercent.toStringAsFixed(0)}% off',
                                icon: Icons.local_offer_outlined,
                                accent: true,
                              ),
                            ],
                            SizedBox(height: AppSpacing.xs.h),
                            _TagChip(
                              label: dealTypeLabel,
                              icon: Icons.storefront_outlined,
                            ),
                            SizedBox(height: AppSpacing.sm.h),
                            Row(
                              children: [
                                Icon(Icons.visibility_outlined, size: 14, color: muted),
                                SizedBox(width: 4.w),
                                Text(
                                  '${offer.viewCount} views',
                                  style: tt.labelMedium?.copyWith(
                                    color: muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm.w),
                                InkWell(
                                  onTap: onToggleOfferLike,
                                  borderRadius: AppBorders.full,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xxs.w,
                                      vertical: 2.h,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          offer.isLiked
                                              ? Icons.thumb_up_rounded
                                              : Icons.thumb_up_outlined,
                                          size: 14,
                                          color: offer.isLiked
                                              ? cs.primary
                                              : muted,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '${offer.likeCount}',
                                          style: tt.labelMedium?.copyWith(
                                            color: offer.isLiked
                                                ? cs.primary
                                                : muted,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      ClipRRect(
                        borderRadius: AppBorders.md,
                        child: NetworkImageWithFallback(
                          primaryUrl: imageUrl,
                          debugLabel: 'discount ${offer.title}',
                          width: 104,
                          height: 96,
                          fit: BoxFit.cover,
                          borderRadius: AppBorders.md,
                          errorWidget: Container(
                            width: 104.w,
                            height: 96.h,
                            color: cs.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(Icons.local_offer_outlined, color: muted),
                          ),
                        ),
                      ),
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

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.icon,
    this.accent = false,
  });

  final String label;
  final IconData icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final backgroundColor = accent
        ? DiscountOfferCard._discountColor.withValues(alpha: 0.12)
        : cs.surfaceContainerHigh;
    final foregroundColor =
        accent ? const Color(0xFF9A5200) : cs.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs.w,
        vertical: AppSpacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppBorders.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: accent ? DiscountOfferCard._discountColor : cs.onSurfaceVariant,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
