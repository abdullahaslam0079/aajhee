/// Human-readable labels for commerce enums.
///
/// Mirrors `aajhee-web/src/lib/commerce.ts` so the customer app and the
/// merchant web app describe the same backend values with the same words.
library;

const Map<String, String> orderStatusLabels = {
  'pending': 'Pending',
  'accepted': 'Accepted',
  'cancelled': 'Cancelled',
  'awaiting_payment': 'Awaiting payment',
  'payment_submitted': 'Payment submitted',
  'paid_confirmed': 'Paid',
  'preparing': 'Preparing',
  'ready_for_pickup': 'Ready for pickup',
  'out_for_delivery': 'Out for delivery',
  'completed': 'Completed',
};

const Map<String, String> fulfillmentLabels = {
  'pickup': 'Pickup',
  'local_same_day': 'Local delivery',
  'nationwide': 'Nationwide',
};

const Map<String, String> paymentLabels = {
  'cash_on_pickup': 'Cash on pickup',
  'cash_on_delivery': 'Cash on delivery',
  'bank_transfer': 'Bank transfer',
  'stripe': 'Card',
  'jazzcash': 'JazzCash',
};

const Map<String, String> paymentProofReviewLabels = {
  'pending': 'Under review',
  'accepted': 'Accepted',
  'rejected': 'Rejected',
};

const Map<String, String> cancelledByLabels = {
  'customer': 'You',
  'business': 'The shop',
  'system': 'System',
};

String _fallback(String? value, {String empty = ''}) {
  if (value == null || value.isEmpty) return empty;
  return value.replaceAll('_', ' ');
}

String labelStatus(String? status) =>
    orderStatusLabels[status] ?? _fallback(status, empty: 'Unknown');

String labelFulfillment(String? value) =>
    fulfillmentLabels[value] ?? _fallback(value);

String labelPayment(String? value) => paymentLabels[value] ?? _fallback(value);

String labelPaymentProofReview(String? value) =>
    paymentProofReviewLabels[value] ?? _fallback(value);

String labelCancelledBy(String? value) =>
    cancelledByLabels[value] ?? _fallback(value);

bool isPickupFulfillment(String? value) => value == 'pickup';

bool isDeliveryFulfillment(String? value) =>
    value == 'local_same_day' || value == 'nationwide';

/// Formats an ISO-8601 timestamp as e.g. `27 Sep 2026, 8:05 PM` in local
/// time. Returns `—` for null/empty and the raw value if it cannot be parsed.
String formatCommerceDateTime(String? value) {
  if (value == null || value.isEmpty) return '—';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final local = parsed.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '${local.day} ${months[local.month - 1]} ${local.year}, '
      '$hour12:$minute $period';
}
