part of 'package:aajhee/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';

class _OnboardingIllustrationState extends State<OnboardingIllustration>
    with SingleTickerProviderStateMixin, OnboardingIllustrationController {
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final drift =
            widget.animate ? (_floatController.value - 0.5) * 10.h : 0.0;
        return Transform.translate(
          offset: Offset(0, drift),
          child: child,
        );
      },
      child: SizedBox(
        width: 280.w,
        height: 280.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _GlowOrb(
              size: 240.w,
              color: widget.accentColor.withValues(alpha: 0.12),
              drift: _floatController,
              driftFactor: -6.h,
            ),
            _GlowOrb(
              size: 160.w,
              color: widget.secondaryColor.withValues(alpha: 0.18),
              offset: Offset(-48.w, -36.h),
              drift: _floatController,
              driftFactor: 8.h,
            ),
            _GlowOrb(
              size: 96.w,
              color: widget.accentColor.withValues(alpha: 0.1),
              offset: Offset(72.w, 64.h),
              drift: _floatController,
              driftFactor: -5.h,
            ),
            Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accentColor.withValues(alpha: 0.14),
                    widget.secondaryColor.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(40.r),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.12),
                    blurRadius: 32,
                    offset: Offset(0, 16.h),
                  ),
                ],
              ),
              child: Center(child: _buildScene(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScene(BuildContext context) {
    return switch (widget.type) {
      OnboardingIllustrationType.localShops => _LocalShopsScene(
          accentColor: widget.accentColor,
          secondaryColor: widget.secondaryColor,
          drift: _floatController,
        ),
      OnboardingIllustrationType.sameDayDelivery => _SameDayDeliveryScene(
          accentColor: widget.accentColor,
          secondaryColor: widget.secondaryColor,
          drift: _floatController,
        ),
      OnboardingIllustrationType.orderPayOnDelivery => _OrderPayOnDeliveryScene(
          accentColor: widget.accentColor,
          secondaryColor: widget.secondaryColor,
          drift: _floatController,
        ),
    };
  }
}
