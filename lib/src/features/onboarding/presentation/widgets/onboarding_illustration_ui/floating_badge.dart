part of 'package:aajhee/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';

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
