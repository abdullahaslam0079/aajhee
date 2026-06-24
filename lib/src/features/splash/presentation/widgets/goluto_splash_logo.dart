import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:goluto/src/imports/packages_imports.dart';

/// Animated Goluto wordmark for the splash screen.
///
/// "Go" pops in first with a subtle idle motion, then "luto" slides in and
/// attaches to form the full logo.
class GolutoSplashLogo extends StatefulWidget {
  const GolutoSplashLogo({super.key});

  static const duration = Duration(milliseconds: 2800);

  @override
  State<GolutoSplashLogo> createState() => _GolutoSplashLogoState();
}

class _GolutoSplashLogoState extends State<GolutoSplashLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: GolutoSplashLogo.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final logoStyle = TextStyle(
      fontSize: 56.sp,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.5,
      height: 1,
      color: colorScheme.primary,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        final goScale = _goScale(t);
        final goWiggle = _goWiggle(t);
        final lutoReveal = _lutoReveal(t);

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Transform.translate(
              offset: goWiggle,
              child: Transform.rotate(
                angle: _goRotation(t),
                child: Transform.scale(
                  scale: goScale,
                  alignment: Alignment.center,
                  child: Text('Go', style: logoStyle),
                ),
              ),
            ),
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: lutoReveal.width,
                child: Opacity(
                  opacity: lutoReveal.opacity,
                  child: Transform.translate(
                    offset: Offset(lutoReveal.slide, 0),
                    child: Text('luto', style: logoStyle),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _goScale(double t) {
    if (t <= 0.14) {
      return Curves.easeOutBack.transform(t / 0.14);
    }
    return 1;
  }

  Offset _goWiggle(double t) {
    if (t <= 0.14 || t >= 0.57) return Offset.zero;

    final idle = (t - 0.14) / (0.57 - 0.14);
    return Offset(
      math.sin(idle * math.pi * 6) * 3.5,
      math.sin(idle * math.pi * 4) * 1.5,
    );
  }

  double _goRotation(double t) {
    if (t <= 0.14 || t >= 0.57) return 0;

    final idle = (t - 0.14) / (0.57 - 0.14);
    return math.sin(idle * math.pi * 5) * 0.018;
  }

  _LutoReveal _lutoReveal(double t) {
    if (t <= 0.57) {
      return const _LutoReveal(width: 0, opacity: 0, slide: 48);
    }

    final progress = Curves.easeOutCubic.transform(
      ((t - 0.57) / (0.86 - 0.57)).clamp(0.0, 1.0),
    );

    return _LutoReveal(
      width: progress,
      opacity: (progress * 1.4).clamp(0.0, 1.0),
      slide: (1 - progress) * 48,
    );
  }
}

class _LutoReveal {
  const _LutoReveal({
    required this.width,
    required this.opacity,
    required this.slide,
  });

  final double width;
  final double opacity;
  final double slide;
}
