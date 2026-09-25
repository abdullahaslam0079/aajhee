import 'package:flutter/material.dart';
import 'package:aajhee/src/shared/app_assets.dart';

/// Aajhee wordmark: "aaj" lands first, brief pause, then "hee" flows in.
/// Uses cropped slices of the brand logo so the typeface matches exactly.
class AajheeSplashLogo extends StatefulWidget {
  const AajheeSplashLogo({super.key});

  static const duration = Duration(milliseconds: 2500);

  @override
  State<AajheeSplashLogo> createState() => _AajheeSplashLogoState();
}

class _AajheeSplashLogoState extends State<AajheeSplashLogo>
    with SingleTickerProviderStateMixin {
  static const _aajStart = 0.06;
  static const _aajDuration = 0.34;

  static const _heeStart = 0.48;
  static const _heeOpenDuration = 0.18;
  static const _heeFadeDuration = 0.28;

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
    return curve.transform(((t - start) / duration).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final logoHeight = (screenWidth * 0.1).clamp(36.0, 56.0);
    // Caps how large "aaj" grows alone (before "hee"); still bold, less huge.
    final maxLogoWidth = screenWidth * 0.52;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        final aajProgress = _interval(
          t,
          _aajStart,
          _aajDuration,
          curve: Curves.easeOutCubic,
        );

        final heeOpen = _interval(
          t,
          _heeStart,
          _heeOpenDuration,
          curve: Curves.easeInOutCubic,
        );

        final heeFade = _interval(
          t,
          _heeStart,
          _heeFadeDuration,
          curve: Curves.easeOutQuart,
        );

        var aajScale = 1.0;
        if (t < _heeStart) {
          aajScale = 1 + aajProgress * 0.02;
        } else if (t < _settleStart) {
          final p = Curves.easeInOutCubic.transform(
            ((t - _heeStart) / (_settleStart - _heeStart)).clamp(0.0, 1.0),
          );
          aajScale = 1.02 - p * 0.02;
        }

        var wordScale = 1.0;
        if (t >= _settleStart) {
          final p = Curves.easeInOutCubic.transform(
            ((t - _settleStart) / (1 - _settleStart)).clamp(0.0, 1.0),
          );
          wordScale = 1 + (1 - p) * 0.008;
        }

        final aajSlide = 10.0 * (1 - aajProgress);
        final heeSlide = 12.0 * (1 - heeFade);

        return SizedBox(
          width: maxLogoWidth,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Transform.scale(
              scale: wordScale,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: aajProgress,
                    child: Transform.translate(
                      offset: Offset(0, aajSlide),
                      child: Transform.scale(
                        scale: aajScale,
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          AppAssets.splashAaj,
                          height: logoHeight,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ),
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: heeOpen.clamp(0.001, 1.0),
                      child: Opacity(
                        opacity: heeFade,
                        child: Transform.translate(
                          offset: Offset(heeSlide, heeSlide * 0.3),
                          child: Image.asset(
                            AppAssets.splashHee,
                            height: logoHeight,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
