import 'package:goluto/src/features/availedOffers/data/models/availed_offer_model.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class AvailedOfferCard extends StatelessWidget {
  const AvailedOfferCard({
    super.key,
    required this.availedOffer,
    this.onTap,
  });

  final AvailedOfferModel availedOffer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.62);
    final offer = availedOffer.offer;
    final branch = availedOffer.branch;

    return Material(
      color: Colors.transparent,
      borderRadius: AppBorders.lg,
      child: InkWell(
        borderRadius: AppBorders.lg,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm.r),
          decoration: BoxDecoration(
            color: cs.onPrimary,
            borderRadius: AppBorders.lg,
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StoreLogoBadge(
                    name: branch.businessName,
                    size: 42,
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.businessName,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          branch.name,
                          style: tt.bodySmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: AppBorders.full,
                    ),
                    child: Text(
                      '${offer.discountPercent.toStringAsFixed(0)}% off',
                      style: tt.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.title,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (offer.subtitle.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.xxs.h),
                          Text(
                            offer.subtitle,
                            style: tt.bodyMedium?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        SizedBox(height: AppSpacing.sm.h),
                        Row(
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 16,
                              color: cs.primary,
                            ),
                            SizedBox(width: AppSpacing.xxs.w),
                            Expanded(
                              child: Text(
                                branch.formattedAddress,
                                style: tt.bodySmall?.copyWith(
                                  color: muted,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: muted,
                            ),
                            SizedBox(width: AppSpacing.xxs.w),
                            Text(
                              'Availed ${formatAvailedOfferDate(availedOffer.redeemedAt)}',
                              style: tt.bodySmall?.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.sm.h),
                        _TagChip(
                          label: offer.offerType == OfferType.item
                              ? 'Item deal'
                              : 'Dine in',
                          icon: Icons.local_offer_outlined,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  ClipRRect(
                    borderRadius: AppBorders.md,
                    child: NetworkImageWithFallback(
                      primaryUrl: offer.imageUrl,
                      debugLabel: 'availed offer ${offer.title}',
                      width: 96,
                      height: 88,
                      fit: BoxFit.cover,
                      borderRadius: AppBorders.md,
                      errorWidget: Container(
                        width: 96.w,
                        height: 88.h,
                        color: cs.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.fastfood_outlined,
                          color: muted,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: AppBorders.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          SizedBox(width: AppSpacing.xxs.w),
          Text(
            label,
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
