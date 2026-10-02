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

    final base = HSLColor.fromColor(cs.primary);
    final light = base
        .withLightness((base.lightness + 0.16).clamp(0.0, 1.0))
        .withSaturation((base.saturation + 0.06).clamp(0.0, 1.0))
        .toColor();
    final mid = cs.primary;
    final dark = base
        .withLightness((base.lightness - 0.14).clamp(0.0, 1.0))
        .withSaturation((base.saturation + 0.04).clamp(0.0, 1.0))
        .toColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: AppBorders.full,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, mid, dark],
          stops: const [0.0, 0.48, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.28),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: cs.onPrimary),
          SizedBox(width: 4.w),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
