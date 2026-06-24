import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:goluto/src/imports/packages_imports.dart';

/// Animated Goluto wordmark: "Go" appears, "luto" slams in from the left,
/// G drops grounded and o launches upward, then the word reassembles.
class GolutoSplashLogo extends StatefulWidget {
  const GolutoSplashLogo({super.key});

  static const duration = Duration(milliseconds: 4000);

  @override
  State<GolutoSplashLogo> createState() => _GolutoSplashLogoState();
}

class _GolutoSplashLogoState extends State<GolutoSplashLogo>
    with SingleTickerProviderStateMixin {
  static const _letters = ['G', 'o', 'l', 'u', 't', 'o'];

  static const _goHeroScale = 1.42;

  static const _goInEnd = 0.16;
  static const _lutoFlyStart = 0.34;
  static const _impact = 0.48;
  static const _crashEnd = 0.68;
  static const _settleEnd = 0.94;

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
      fontSize: 54.sp,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1,
      color: colorScheme.primary,
    );
    final heroGoStyle = logoStyle.copyWith(
      fontSize: 54.sp * _goHeroScale,
      letterSpacing: 0,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final shake = _screenShake(t);
        final flash = _impactFlash(t);
        final showFlyingLuto = t >= _lutoFlyStart && t < _impact;
        final wordPulse = _finalPulse(t);

        final showHeroGo = t < _impact;

        return Transform.translate(
          offset: shake,
          child: Transform.scale(
            scale: wordPulse,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (showFlyingLuto) _SpeedLines(t: t, color: colorScheme.primary),
                if (flash > 0) _ImpactBurst(flash: flash, color: colorScheme.primary),
                if (t >= _impact && t < _crashEnd + 0.08)
                  _ImpactDust(t: t, color: colorScheme.primary),
                if (showHeroGo) _buildHeroGo(t, heroGoStyle),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: List.generate(
                    _letters.length,
                    (index) => _buildLetter(index, t, logoStyle),
                  ),
                ),
                if (showFlyingLuto)
                  Transform.translate(
                    offset: _flyingLutoOffset(t),
                    child: Transform.scale(
                      scaleX: 1.18,
                      scaleY: 0.92,
                      alignment: Alignment.centerRight,
                      child: Text('luto', style: logoStyle),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroGo(double t, TextStyle style) {
    final scale = _goSizeScale(t) / _goHeroScale;
    final opacity = t < _goInEnd ? Curves.easeOut.transform(t / _goInEnd) : 1.0;
    final offset = _goIdleOffset(t) + _goAnticipation(t);

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: offset,
        child: Transform.scale(
          scale: scale,
          child: Text('Go', style: style),
        ),
      ),
    );
  }

  Widget _buildLetter(int index, double t, TextStyle style) {
    final inRow = (index > 1 && t >= _impact) || (index <= 1 && t >= _impact);
    if (!inRow) return const SizedBox.shrink();

    final transform = _letterTransform(index, t);
    final entrance = _letterEntrance(index, t);
    final goScale = index <= 1 ? _goSizeScale(t) : 1.0;
    final letterStyle = index <= 1 && t >= _impact
        ? style.copyWith(fontSize: 54.sp * goScale)
        : style;

    return Padding(
      padding: _letterOverflowPadding(index, t),
      child: Opacity(
        opacity: entrance.opacity,
        child: Transform.translate(
          offset: transform.offset +
              (index == 1 && t >= _impact
                  ? Offset(6.w * (goScale - 1), 0)
                  : Offset.zero),
          child: Transform.rotate(
            angle: transform.rotation,
            alignment: transform.pivot,
            child: Transform(
              alignment: transform.pivot,
              transform: Matrix4.identity()
                ..scale(
                  transform.scaleX * entrance.scale,
                  transform.scaleY * entrance.scale,
                ),
              child: Text(_letters[index], style: letterStyle),
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets _letterOverflowPadding(int index, double t) {
    if (t < _impact || t >= _settleEnd) return EdgeInsets.zero;

    final fade = t < _crashEnd
        ? 1.0
        : 1 - ((t - _crashEnd) / (_settleEnd - _crashEnd)).clamp(0, 1);

    if (index == 0) {
      return EdgeInsets.only(left: 22.w * fade, bottom: 54.h * fade, right: 4.w * fade);
    }
    if (index == 1) {
      return EdgeInsets.only(top: 78.h * fade, bottom: 8.h * fade, right: 2.w * fade);
    }
    return EdgeInsets.zero;
  }

  /// "Go" starts large, then scales down to match the full wordmark.
  double _goSizeScale(double t) {
    if (t < _goInEnd) {
      final p = Curves.easeOutBack.transform(t / _goInEnd);
      return 0.55 + p * (_goHeroScale - 0.55);
    }
    if (t < _impact) return _goHeroScale;
    if (t < _settleEnd) {
      final p = Curves.easeInOutCubic.transform(
        (t - _impact) / (_settleEnd - _impact),
      );
      return _goHeroScale + (1 - _goHeroScale) * p;
    }
    return 1;
  }

  _LetterEntrance _letterEntrance(int index, double t) {
    if (index <= 1) {
      if (t >= _goInEnd) {
        return const _LetterEntrance(opacity: 1, scale: 1);
      }
      return _LetterEntrance(
        opacity: Curves.easeOut.transform(t / _goInEnd),
        scale: 1,
      );
    }

    if (t < _impact) {
      return const _LetterEntrance(opacity: 0, scale: 1);
    }

    final delay = 0.04 + (index - 2) * 0.025;
    final start = _impact + delay;
    if (t <= start) {
      return const _LetterEntrance(opacity: 0, scale: 1);
    }

    final p = Curves.easeOut.transform(
      ((t - start) / 0.12).clamp(0, 1),
    );
    return _LetterEntrance(opacity: p, scale: 1);
  }

  _LetterTransform _letterTransform(int index, double t) {
    if (index <= 1) {
      return _goLetterTransform(index, t);
    }
    return _lutoLetterTransform(index, t);
  }

  _LetterTransform _goLetterTransform(int index, double t) {
    final idle = _goIdleOffset(t) + _goAnticipation(t);

    if (t < _impact) {
      return _LetterTransform(offset: idle, pivot: Alignment.bottomCenter);
    }

    if (t < _crashEnd) {
      final p = (t - _impact) / (_crashEnd - _impact);

      if (index == 0) {
        final fall = Curves.easeInCubic.transform(p.clamp(0, 0.72) / 0.72);
        final squash = p > 0.72
            ? Curves.easeOut.transform(((p - 0.72) / 0.28).clamp(0, 1))
            : 0.0;

        return _LetterTransform(
          offset: idle + Offset(-14.w * fall, 48.h * fall),
          rotation: 0.32 * fall,
          scaleX: 1 + squash * 0.1,
          scaleY: 1 - fall * 0.06 - squash * 0.08,
          pivot: Alignment.bottomCenter,
        );
      }

      final launch = Curves.easeOutCubic.transform((p / 0.45).clamp(0, 1));
      final hang = p > 0.45
          ? math.sin(((p - 0.45) / 0.55) * math.pi * 3) * 0.04
          : 0.0;

      return _LetterTransform(
        offset: idle + Offset(14.w * launch, -72.h * launch + hang * 18.h),
        rotation: -0.26 * launch + hang * 0.08,
        scaleX: 0.96 + launch * 0.04,
        scaleY: 1 + launch * 0.06,
        pivot: Alignment.bottomCenter,
      );
    }

    if (t < _settleEnd) {
      final delay = index == 0 ? 0.0 : 0.05;
      final p = Curves.elasticOut.transform(
        ((t - _crashEnd - delay) / (_settleEnd - _crashEnd - delay))
            .clamp(0, 1),
      );

      if (index == 0) {
        return _LetterTransform(
          offset: Offset(-14.w * (1 - p), 48.h * (1 - p)),
          rotation: 0.32 * (1 - p),
          scaleX: 1.1 - p * 0.1,
          scaleY: 0.86 + p * 0.14,
          pivot: Alignment.bottomCenter,
        );
      }

      return _LetterTransform(
        offset: Offset(14.w * (1 - p), -72.h * (1 - p)),
        rotation: -0.26 * (1 - p),
        scaleX: 1 - p * 0.04,
        scaleY: 1.06 - p * 0.06,
        pivot: Alignment.bottomCenter,
      );
    }

    return const _LetterTransform(pivot: Alignment.bottomCenter);
  }

  _LetterTransform _lutoLetterTransform(int index, double t) {
    if (t < _impact) {
      return const _LetterTransform();
    }

    final slot = index - 2;
    final delay = 0.08 + slot * 0.035;

    if (t >= _settleEnd) {
      return const _LetterTransform(pivot: Alignment.bottomCenter);
    }

    final p = Curves.elasticOut.transform(
      ((t - _impact - delay) / (_settleEnd - _impact - delay)).clamp(0, 1),
    );
    final gather = Offset((-124 + slot * 12).w * (1 - p), 16.h * (1 - p));

    return _LetterTransform(
      offset: gather,
      rotation: (slot - 1.5) * 0.14 * (1 - p),
      scaleX: 0.88 + p * 0.12,
      scaleY: 0.88 + p * 0.12,
      pivot: Alignment.bottomCenter,
    );
  }

  Offset _goIdleOffset(double t) {
    if (t <= _goInEnd || t >= _lutoFlyStart) return Offset.zero;

    final idle = (t - _goInEnd) / (_lutoFlyStart - _goInEnd);
    return Offset(math.sin(idle * math.pi * 3) * 2, 0);
  }

  Offset _goAnticipation(double t) {
    if (t < _lutoFlyStart + 0.05 || t >= _impact) return Offset.zero;

    final p = (t - (_lutoFlyStart + 0.05)) / (_impact - (_lutoFlyStart + 0.05));
    return Offset(10.w * Curves.easeIn.transform(p), -2.h * p);
  }

  Offset _flyingLutoOffset(double t) {
    if (t < _lutoFlyStart) return Offset(-300.w, 0);

    final p = Curves.easeInExpo.transform(
      (t - _lutoFlyStart) / (_impact - _lutoFlyStart),
    );
    return Offset(-300.w + p * 262.w, 0);
  }

  Offset _screenShake(double t) {
    if (t < _impact || t > _impact + 0.14) return Offset.zero;

    final p = (t - _impact) / 0.14;
    final decay = 1 - p;
    final amp = 10.w * decay;
    return Offset(
      math.sin(p * math.pi * 14) * amp,
      math.cos(p * math.pi * 11) * amp * 0.6,
    );
  }

  double _impactFlash(double t) {
    if (t < _impact || t > _impact + 0.08) return 0;
    final p = (t - _impact) / 0.08;
    return (1 - p) * (1 - p);
  }

  double _finalPulse(double t) {
    if (t < _settleEnd) return 1;
    final p = ((t - _settleEnd) / (1 - _settleEnd)).clamp(0, 1);
    return 1 + math.sin(p * math.pi) * 0.035 * (1 - p);
  }
}

class _SpeedLines extends StatelessWidget {
  const _SpeedLines({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = ((t - _GolutoSplashLogoState._lutoFlyStart) /
            (_GolutoSplashLogoState._impact -
                _GolutoSplashLogoState._lutoFlyStart))
        .clamp(0.0, 1.0);
    final opacity = (progress * 0.35).clamp(0.0, 0.35);

    return SizedBox(
      width: 220.w,
      height: 60.h,
      child: CustomPaint(
        painter: _SpeedLinesPainter(
          color: color.withValues(alpha: opacity),
          intensity: progress,
        ),
      ),
    );
  }
}

class _SpeedLinesPainter extends CustomPainter {
  _SpeedLinesPainter({required this.color, required this.intensity});

  final Color color;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.25 + i * 0.12);
      final length = size.width * (0.25 + intensity * 0.45);
      final x = size.width * 0.1 + i * 6;
      canvas.drawLine(Offset(x, y), Offset(x + length, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedLinesPainter oldDelegate) {
    return oldDelegate.intensity != intensity || oldDelegate.color != color;
  }
}

class _ImpactBurst extends StatelessWidget {
  const _ImpactBurst({required this.flash, required this.color});

  final double flash;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (120 + flash * 40).w,
      height: (120 + flash * 40).w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: flash * 0.22),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _ImpactDust extends StatelessWidget {
  const _ImpactDust({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = ((t - _GolutoSplashLogoState._impact) / 0.12).clamp(0.0, 1.0);
    final fade = 1 - p;

    return SizedBox(
      width: 160.w,
      height: 100.h,
      child: CustomPaint(
        painter: _DustPainter(
          color: color.withValues(alpha: fade * 0.45),
          spread: p,
        ),
      ),
    );
  }
}

class _DustPainter extends CustomPainter {
  _DustPainter({required this.color, required this.spread});

  final Color color;
  final double spread;

  static const _offsets = [
    Offset(-0.35, -0.1),
    Offset(-0.15, 0.25),
    Offset(0.1, -0.2),
    Offset(0.28, 0.15),
    Offset(-0.05, 0.35),
    Offset(0.35, -0.05),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width * 0.45, size.height * 0.55);

    for (final origin in _offsets) {
      final pos = center +
          Offset(
            origin.dx * size.width * (0.4 + spread),
            origin.dy * size.height * (0.4 + spread),
          );
      canvas.drawCircle(pos, 2.5 * (1 - spread * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter oldDelegate) {
    return oldDelegate.spread != spread || oldDelegate.color != color;
  }
}

class _LetterEntrance {
  const _LetterEntrance({required this.opacity, required this.scale});

  final double opacity;
  final double scale;
}

class _LetterTransform {
  const _LetterTransform({
    this.offset = Offset.zero,
    this.rotation = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.pivot = Alignment.center,
  });

  final Offset offset;
  final double rotation;
  final double scaleX;
  final double scaleY;
  final Alignment pivot;
}
