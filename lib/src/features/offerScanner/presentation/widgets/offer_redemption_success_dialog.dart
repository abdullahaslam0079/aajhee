import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/offerScanner/domain/offer_usage_status.dart';
import 'package:goluto/src/features/offerScanner/presentation/widgets/offer_usage_status_banner.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class OfferRedemptionSuccessDialog extends StatefulWidget {
  const OfferRedemptionSuccessDialog({
    super.key,
    required this.offer,
    required this.usageStatus,
    this.autoCloseAfter = const Duration(seconds: 3),
  });

  final OfferModel offer;
  final OfferUsageStatus usageStatus;
  final Duration autoCloseAfter;

  static Future<void> show(
    BuildContext context, {
    required OfferModel offer,
    required OfferUsageStatus usageStatus,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => OfferRedemptionSuccessDialog(
        offer: offer,
        usageStatus: usageStatus,
      ),
    );
  }

  @override
  State<OfferRedemptionSuccessDialog> createState() =>
      _OfferRedemptionSuccessDialogState();
}

class _OfferRedemptionSuccessDialogState
    extends State<OfferRedemptionSuccessDialog> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.autoCloseAfter, _close);
  }

  void _close() {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.65);
    final offer = widget.offer;

    return Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.lg),
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 40,
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              'Offer redeemed!',
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              'You successfully availed this deal',
              style: tt.bodyMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg.h),
            OfferUsageStatusBanner(status: widget.usageStatus),
            SizedBox(height: AppSpacing.lg.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.ms.r),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs.h),
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
                          offer.businessName,
                          style: tt.bodyMedium?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (offer.subtitle.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.sm.h),
                    Text(
                      offer.subtitle,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  SizedBox(height: AppSpacing.sm.h),
                  Wrap(
                    spacing: AppSpacing.xs.w,
                    runSpacing: AppSpacing.xs.h,
                    children: [
                      if (offer.discountPercent > 0)
                        _DetailChip(
                          icon: Icons.local_offer_outlined,
                          label:
                              '${offer.discountPercent.toStringAsFixed(0)}% off',
                          colorScheme: cs,
                          textTheme: tt,
                        ),
                      _DetailChip(
                        icon: Icons.category_outlined,
                        label: offer.categoryName,
                        colorScheme: cs,
                        textTheme: tt,
                      ),
                      if (offer.detailText.isNotEmpty)
                        _DetailChip(
                          icon: Icons.info_outline_rounded,
                          label: offer.detailText,
                          colorScheme: cs,
                          textTheme: tt,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _close,
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs.w,
        vertical: AppSpacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppBorders.sm,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
