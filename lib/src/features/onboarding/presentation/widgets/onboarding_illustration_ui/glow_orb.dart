part of 'package:aajhee/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';

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
