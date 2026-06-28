import 'package:goluto/src/features/offerScanner/domain/offer_usage_status.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class OfferUsageStatusBanner extends StatelessWidget {
  const OfferUsageStatusBanner({
    super.key,
    required this.status,
    this.compact = false,
  });

  final OfferUsageStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isAvailable = status.isAvailable;

    final backgroundColor = isAvailable
        ? cs.primary.withValues(alpha: 0.08)
        : cs.errorContainer.withValues(alpha: 0.35);
    final foregroundColor =
        isAvailable ? cs.primary : cs.onErrorContainer;
    final icon = isAvailable
        ? Icons.check_circle_outline_rounded
        : Icons.block_rounded;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: compact ? AppSpacing.xxs.h : AppSpacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppBorders.sm,
        border: Border.all(
          color: foregroundColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: compact ? 16 : 18, color: foregroundColor),
          SizedBox(width: AppSpacing.xxs.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.availabilityLabel,
                  style: (compact ? tt.labelMedium : tt.labelLarge)?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!compact) ...[
                  SizedBox(height: 2.h),
                  Text(
                    status.limitDescription,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
