part of 'package:aajhee/src/features/commerce/presentation/screens/order_detail_screen.dart';

class _CancelSection extends StatelessWidget {
  const _CancelSection({
    required this.order,
    required this.cancelling,
    required this.onCancel,
    required this.pendingBlockedReason,
  });

  final OrderDetail order;
  final bool cancelling;
  final VoidCallback onCancel;
  final String pendingBlockedReason;

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    final canCancel = order.canCustomerCancel;
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        );

    if (canCancel) {
      final until = order.customerCancelUntil;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(
            onPressed: cancelling ? null : onCancel,
            child: Text(cancelling ? 'Cancelling…' : 'Cancel order'),
          ),
          if (until.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Text(
                'Cancel until ${formatCommerceDateTime(until)}',
                textAlign: TextAlign.center,
                style: small,
              ),
            ),
        ],
      );
    }

    if (status == 'pending') {
      return Text(pendingBlockedReason, style: small);
    }
    if (status == 'cancelled' || status == 'completed') {
      return const SizedBox.shrink();
    }
    return Text(
      'This order can no longer be cancelled. Contact the shop if you need help.',
      style: small,
    );
  }
}
