part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.ms.w,
        AppSpacing.xs.h,
        AppSpacing.ms.w,
        2.h,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          SizedBox(width: 5.w),
          Expanded(
            child: Text(
              title,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                fontSize: 14.sp,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
