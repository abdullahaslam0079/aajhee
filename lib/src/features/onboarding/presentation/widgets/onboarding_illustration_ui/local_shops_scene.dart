part of 'package:aajhee/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';

class _LocalShopsScene extends StatelessWidget {
  const _LocalShopsScene({
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
              icon: Icons.storefront_rounded,
              color: accentColor,
              size: 52,
              offset: Offset(-58.w, -52.h + (t - 0.5) * 8.h),
              rotation: -0.15,
            ),
            _FloatingBadge(
              icon: Icons.shopping_bag_rounded,
              color: secondaryColor,
              size: 44,
              offset: Offset(62.w, -44.h + (0.5 - t) * 6.h),
              rotation: 0.12,
            ),
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.storefront_rounded,
                size: 42.sp,
                color: Colors.white,
              ),
            ),
            _FloatingBadge(
              icon: Icons.favorite_rounded,
              color: AppBrandColors.lightDeal,
              size: 40,
              offset: Offset(-54.w, 58.h + (t - 0.5) * 5.h),
              rotation: -0.08,
            ),
            _DealChip(
              label: 'onboarding.nearby_label'.tr(),
              color: accentColor,
              offset: Offset(54.w, 52.h + (0.5 - t) * 7.h),
            ),
          ],
        );
      },
    );
  }
}
