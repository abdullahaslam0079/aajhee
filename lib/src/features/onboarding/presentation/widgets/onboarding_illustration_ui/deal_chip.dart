part of 'package:aajhee/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';

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
