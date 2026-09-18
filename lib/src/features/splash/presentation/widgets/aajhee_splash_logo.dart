import 'package:flutter/material.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/theme/app_fonts.dart';

/// Aajhee wordmark: "Go" lands first, brief pause, then "luto" flows in beside it.
class AajheeSplashLogo extends StatefulWidget {
  const AajheeSplashLogo({super.key});

  static const duration = Duration(milliseconds: 2500);

  @override
  State<AajheeSplashLogo> createState() => _AajheeSplashLogoState();
}

class _AajheeSplashLogoState extends State<AajheeSplashLogo>
    with SingleTickerProviderStateMixin {
  static const _letters = ['G', 'o', 'l', 'u', 't', 'o'];

  // Go: ~0.06 → ~0.38
  static const _goStart = 0.06;
  static const _goStagger = 0.05;
  static const _goLetterDuration = 0.26;

  // Short beat, then luto: ~0.46 → ~0.86
  static const _lutoStart = 0.46;
  static const _lutoOpenDuration = 0.16;
  static const _lutoStagger = 0.048;
  static const _lutoLetterDuration = 0.24;

  static const _settleStart = 0.88;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AajheeSplashLogo.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _interval(
    double t,
    double start,
    double duration, {
    Curve curve = Curves.easeOutCubic,
  }) {
    if (t <= start) return 0;
    return curve.transform(((t - start) / duration).clamp(0, 1));
  }

  double _goLetterProgress(int index, double t) {
    return _interval(
      t,
      _goStart + index * _goStagger,
      _goLetterDuration,
      curve: Curves.easeOutCubic,
    );
  }

  double _goProgress(double t) => _goLetterProgress(1, t);

  double _lutoOpen(double t) {
    return _interval(
      t,
      _lutoStart,
      _lutoOpenDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  double _lutoLetterProgress(int index, double t) {
    if (t < _lutoStart) return 0;

    final start = _lutoStart + (index - 2) * _lutoStagger;
    return _interval(
      t,
      start,
      _lutoLetterDuration,
      curve: Curves.easeOutQuart,
    );
  }

  double _goScale(double t) {
    if (t < _lutoStart) {
      return 1 + _goProgress(t) * 0.03;
    }
    if (t >= _settleStart) return 1;

    final p = Curves.easeInOutCubic.transform(
      ((t - _lutoStart) / (_settleStart - _lutoStart)).clamp(0, 1),
    );
    return 1.03 - p * 0.03;
  }

  double _wordScale(double t) {
    if (t < _settleStart) return 1;
    final p = Curves.easeInOutCubic.transform(
      ((t - _settleStart) / (1 - _settleStart)).clamp(0, 1),
    );
    return 1 + (1 - p) * 0.01;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final baseStyle = textTheme.displaySmall?.copyWith(
      fontSize: 54.sp,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1,
      color: colorScheme.primary,
    ) ?? TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 54.sp,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1,
      color: colorScheme.primary,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final goScale = _goScale(t);
        final lutoOpen = _lutoOpen(t);

        return Transform.scale(
          scale: _wordScale(t),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              for (var i = 0; i < 2; i++)
                _AnimatedLetter(
                  letter: _letters[i],
                  progress: _goLetterProgress(i, t),
                  style: baseStyle.copyWith(fontSize: 54.sp * goScale),
                  offset: Offset(0, 14.h),
                ),
              SizedBox(width: 4.w * lutoOpen),
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: lutoOpen.clamp(0.001, 1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      for (var i = 2; i < _letters.length; i++)
                        _AnimatedLetter(
                          letter: _letters[i],
                          progress: _lutoLetterProgress(i, t),
                          style: baseStyle,
                          offset: Offset(16.w, 6.h),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedLetter extends StatelessWidget {
  const _AnimatedLetter({
    required this.letter,
    required this.progress,
    required this.style,
    required this.offset,
  });

  final String letter;
  final double progress;
  final TextStyle style;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);

    return Opacity(
      opacity: p,
      child: Transform.translate(
        offset: Offset(
          offset.dx * (1 - p),
          offset.dy * (1 - p),
        ),
        child: Text(letter, style: style),
      ),
    );
  }
}
