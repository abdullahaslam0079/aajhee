part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _DeliveryChip extends StatelessWidget {
  const _DeliveryChip({
    required this.label,
    required this.icon,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = emphasized
        ? cs.primary.withValues(alpha: 0.12)
        : cs.surfaceContainerHigh;
    final fg = emphasized ? cs.primary : cs.onSurfaceVariant;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppBorders.sm,
        border: Border.all(
          color: emphasized
              ? cs.primary.withValues(alpha: 0.25)
              : cs.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          SizedBox(width: 4.w),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
