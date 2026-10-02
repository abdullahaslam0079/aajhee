part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: AppBorders.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 12, color: cs.primary),
          SizedBox(width: 3.w),
          Text(
            'Verified',
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
