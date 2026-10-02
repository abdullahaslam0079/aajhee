part of 'package:aajhee/src/features/commerce/presentation/screens/order_detail_screen.dart';

class _CancelledInfoCard extends StatelessWidget {
  const _CancelledInfoCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final by = order.cancelledBy;
    final reason = order.cancelReason;
    final at = order.cancelledAt;
    final lines = <String>[
      if (by.isNotEmpty) 'Cancelled by ${labelCancelledBy(by)}',
      if (at.isNotEmpty) 'On ${formatCommerceDateTime(at)}',
      if (reason.isNotEmpty) 'Reason: $reason',
    ];
    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.45),
        borderRadius: AppBorders.card,
        border: Border.all(color: cs.error.withValues(alpha: 0.25)),
      ),
      child: Text(
        lines.join('\n'),
        style: tt.bodyMedium?.copyWith(
          color: cs.onErrorContainer,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }
}
