part of 'package:aajhee/src/features/businessStore/presentation/widgets/business_store_card.dart';

class _DistanceDeliveryRow extends StatelessWidget {
  const _DistanceDeliveryRow({
    required this.distanceLabel,
    required this.deliveryLabel,
    required this.muted,
    required this.textTheme,
    required this.colorScheme,
  });

  final String distanceLabel;
  final String? deliveryLabel;
  final Color muted;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 13,
          color: muted,
        ),
        SizedBox(width: 2.w),
        Text(
          distanceLabel,
          style: textTheme.labelSmall?.copyWith(
            color: muted,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
        if (deliveryLabel != null && deliveryLabel!.isNotEmpty) ...[
          SizedBox(width: 8.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppBrandColors.primaryContainer,
                borderRadius: AppBorders.full,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 12,
                    color: colorScheme.primary,
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      deliveryLabel == 'Same-day'
                          ? 'Same-day delivery'
                          : deliveryLabel!,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
