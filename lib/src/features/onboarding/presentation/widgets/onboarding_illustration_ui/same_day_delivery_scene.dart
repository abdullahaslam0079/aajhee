part of 'package:aajhee/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';

class _SameDayDeliveryScene extends StatelessWidget {
  const _SameDayDeliveryScene({
    required this.accentColor,
    required this.secondaryColor,
    required this.drift,
  });

  final Color accentColor;
  final Color secondaryColor;
  final Animation<double> drift;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: drift,
      builder: (context, _) {
        final t = drift.value;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 130.w,
              height: 130.w,
              decoration: BoxDecoration(
                color: secondaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: CustomPaint(
                painter: _MapGridPainter(
                  color: secondaryColor.withValues(alpha: 0.25),
                ),
              ),
            ),
            _MapPin(
              color: accentColor,
              offset: Offset(-28.w, -18.h + (t - 0.5) * 4.h),
              label: 'Shop',
            ),
            _MapPin(
              color: secondaryColor,
              offset: Offset(34.w, -8.h + (0.5 - t) * 5.h),
              label: 'Cafe',
              scale: 0.85,
            ),
            _MapPin(
              color: accentColor,
              offset: Offset(-8.w, 36.h + (t - 0.5) * 3.h),
              label: 'Market',
              scale: 0.9,
            ),
            Positioned(
              bottom: -8.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_shipping_rounded,
                        size: 14.sp, color: accentColor),
                    SizedBox(width: 4.w),
                    Text(
                      'onboarding.today_label'.tr(),
                      style: context.theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
