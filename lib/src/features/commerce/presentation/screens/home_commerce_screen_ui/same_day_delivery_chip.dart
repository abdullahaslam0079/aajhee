part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _SameDayDeliveryChip extends StatelessWidget {
  const _SameDayDeliveryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSameDay = label == 'Same-day';
    final icon = isSameDay
        ? Icons.delivery_dining_rounded
        : Icons.local_shipping_outlined;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: AppBorders.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: cs.onPrimary),
          SizedBox(width: 3.w),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  fontSize: 9.sp,
                ),
          ),
        ],
      ),
    );
  }
}
