part of 'package:aajhee/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';

class _OrderPayOnDeliveryScene extends StatelessWidget {
  const _OrderPayOnDeliveryScene({
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
            _FloatingBadge(
              icon: Icons.shopping_bag_rounded,
              color: accentColor,
              size: 48,
              offset: Offset(-62.w, -48.h + (t - 0.5) * 8.h),
              rotation: -0.12,
            ),
            _FloatingBadge(
              icon: Icons.payments_rounded,
              color: secondaryColor,
              size: 46,
              offset: Offset(60.w, -40.h + (0.5 - t) * 7.h),
              rotation: 0.1,
            ),
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 46.sp,
                color: Colors.white,
              ),
            ),
            _DealChip(
              label: 'Order',
              color: secondaryColor,
              offset: Offset(-70.w, 52.h + (t - 0.5) * 4.h),
            ),
            _DealChip(
              label: 'onboarding.cod_label'.tr(),
              color: accentColor,
              offset: Offset(48.w, 56.h + (0.5 - t) * 4.h),
            ),
          ],
        );
      },
    );
  }
}
