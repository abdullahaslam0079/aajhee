part of 'package:aajhee/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';

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
