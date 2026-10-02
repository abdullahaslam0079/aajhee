part of 'package:aajhee/src/features/commerce/presentation/screens/orders_screen.dart';

class _OrderListCard extends StatelessWidget {
  const _OrderListCard({
    required this.order,
    required this.onTap,
  });

  final OrderSummary order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final status = order.status.isEmpty ? null : order.status;
    final (statusColor, statusBg) = orderStatusColors(context, status);
    final itemCount =
        order.lines.fold<int>(0, (sum, line) => sum + line.quantity);
    final firstName =
        order.lines.isEmpty ? null : order.lines.first.productName;
    final itemSummary = itemCount <= 0
        ? 'No items'
        : itemCount == 1
            ? ((firstName?.isNotEmpty ?? false) ? firstName! : '1 item')
            : (firstName?.isNotEmpty ?? false)
                ? '$firstName + ${itemCount - 1} more'
                : '$itemCount items';
    final placedAt = formatCommerceDateTime(order.placedAt);
    final orderNumber = formatOrderNumber(order.publicId);

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppBorders.card,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.businessName.isEmpty
                            ? 'Order'
                            : order.businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      'Rs ${order.total}',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  itemSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: AppBorders.sm,
                      ),
                      child: Text(
                        labelStatus(status),
                        style: tt.labelMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        [
                          labelFulfillment(order.fulfillmentType),
                          labelPayment(order.paymentMethod),
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        placedAt == '—' ? 'Recently placed' : placedAt,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (orderNumber.isNotEmpty)
                      Text(
                        orderNumber,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cs.primary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
