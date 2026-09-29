import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

enum OnboardingIllustrationType {
  localShops,
  sameDayDelivery,
  orderPayOnDelivery,
}

class OnboardingIllustration extends StatefulWidget {
  const OnboardingIllustration({
    super.key,
    required this.type,
    required this.accentColor,
    required this.secondaryColor,
    this.animate = true,
  });

  final OnboardingIllustrationType type;
  final Color accentColor;
  final Color secondaryColor;
  final bool animate;

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    if (widget.animate) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final drift = widget.animate ? (_floatController.value - 0.5) * 10.h : 0.0;
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

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    this.offset = Offset.zero,
    this.drift,
    this.driftFactor = 0,
  });

  final double size;
  final Color color;
  final Offset offset;
  final Animation<double>? drift;
  final double driftFactor;

  @override
  Widget build(BuildContext context) {
    final yDrift = drift != null ? (drift!.value - 0.5) * driftFactor : 0.0;

    return Transform.translate(
      offset: offset + Offset(0, yDrift),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

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
                    Icon(Icons.local_shipping_rounded, size: 14.sp, color: accentColor),
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

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({
    required this.icon,
    required this.color,
    required this.size,
    required this.offset,
    required this.rotation,
  });

  final IconData icon;
  final Color color;
  final double size;
  final Offset offset;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: size.w,
          height: size.w,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Icon(icon, size: (size * 0.48).sp, color: color),
        ),
      ),
    );
  }
}

class _DealChip extends StatelessWidget {
  const _DealChip({
    required this.label,
    required this.color,
    required this.offset,
  });

  final String label;
  final Color color;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Text(
          label,
          style: context.theme.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.color,
    required this.offset,
    required this.label,
    this.scale = 1,
  });

  final Color color;
  final Offset offset;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Transform.scale(
        scale: scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                label,
                style: context.theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(Icons.location_on_rounded, size: 22.sp, color: color),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  _MapGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const divisions = 4;
    for (var i = 1; i < divisions; i++) {
      final x = size.width * i / divisions;
      final y = size.height * i / divisions;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

