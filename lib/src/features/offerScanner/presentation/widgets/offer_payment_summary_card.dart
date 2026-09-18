import 'package:aajhee/src/features/offerScanner/domain/offer_payment_preview.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class OfferPaymentSummaryCard extends StatelessWidget {
  const OfferPaymentSummaryCard({
    super.key,
    required this.payment,
    this.compact = false,
  });

  final OfferPaymentPreview payment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.65);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? AppSpacing.sm.r : AppSpacing.ms.r),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: AppBorders.md,
        border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (payment.summary?.isNotEmpty == true) ...[
            Text(
              payment.summary!,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
          ],
          if (payment.amountToPay != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  payment.amountToPay!.asEuro,
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(width: AppSpacing.xs.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    'to pay',
                    style: tt.bodyMedium?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          if (!compact &&
              payment.originalAmount != null &&
              payment.discountAmount != null) ...[
            SizedBox(height: AppSpacing.sm.h),
            _Line(
              label: 'Bill total',
              value: payment.originalAmount!.asEuro,
              muted: muted,
              tt: tt,
            ),
            SizedBox(height: AppSpacing.xxs.h),
            _Line(
              label: 'You save',
              value: '-${payment.discountAmount!.asEuro}',
              muted: cs.primary,
              tt: tt,
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    required this.muted,
    required this.tt,
  });

  final String label;
  final String value;
  final Color muted;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: tt.bodyMedium?.copyWith(
            color: muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
