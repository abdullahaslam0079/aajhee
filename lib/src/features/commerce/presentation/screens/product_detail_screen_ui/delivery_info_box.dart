part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

class _DeliveryInfoBox extends StatelessWidget {
  const _DeliveryInfoBox({
    required this.city,
    required this.sameDayAvailable,
    this.feeLabel,
  });

  final String city;
  final bool sameDayAvailable;
  final String? feeLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    String? sameDayLine;
    if (sameDayAvailable) {
      if (city.isNotEmpty && feeLabel != null) {
        sameDayLine = 'Delivery today in $city · $feeLabel';
      } else if (city.isNotEmpty) {
        sameDayLine = 'Delivery today in $city';
      } else if (feeLabel != null) {
        sameDayLine = 'Delivery today · $feeLabel';
      } else {
        sameDayLine = 'Delivery today';
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: AppBorders.md,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sameDayLine != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 18,
                  color: cs.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    sameDayLine,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.payments_outlined,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Cash on delivery available',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
