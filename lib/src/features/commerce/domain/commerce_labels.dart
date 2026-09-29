/// Human-readable labels for commerce enums.
///
/// Mirrors `aajhee-web/src/lib/commerce.ts` so the customer app and the
/// merchant web app describe the same backend values with the same words.
library;

const Map<String, String> orderStatusLabels = {
  'pending': 'Pending',
  'accepted': 'Accepted',
  'cancelled': 'Cancelled',
  'awaiting_payment': 'Accepted',
  'payment_submitted': 'Accepted',
  'paid_confirmed': 'Accepted',
  'preparing': 'Accepted',
  'ready_for_pickup': 'Ready for pickup',
  'out_for_delivery': 'Out for delivery',
  'completed': 'Delivered',
};

const Map<String, String> paymentStatusLabels = {
  'unpaid': 'Unpaid',
  'awaiting_confirmation': 'Awaiting confirmation',
  'paid': 'Paid',
};

const Map<String, String> fulfillmentLabels = {
  'pickup': 'In-store pickup',
  'local_same_day': 'Same-day delivery',
  'nationwide': 'Nationwide / standard delivery',
};

const Map<String, String> paymentLabels = {
  'cash_on_pickup': 'Cash on pickup',
  'cash_on_delivery': 'Cash on delivery',
  'bank_transfer': 'Bank transfer',
  'stripe': 'Card',
  'jazzcash': 'Mobile wallet (JazzCash / Easypaisa)',
};

/// Methods where the customer uploads a transaction screenshot at checkout.
const Set<String> paymentProofMethods = {
  'bank_transfer',
  'stripe',
  'jazzcash',
};

bool requiresPaymentProof(String? method) =>
    method != null && paymentProofMethods.contains(method);

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

String labelPaymentStatus(String? status) =>
    paymentStatusLabels[status] ?? _fallback(status, empty: 'Unknown');

String labelFulfillment(String? value, {String? city}) {
  if (value == 'local_same_day') {
    final cleaned = city?.trim() ?? '';
    if (cleaned.isNotEmpty) return 'Same-day delivery in $cleaned';
    return fulfillmentLabels[value]!;
  }
  return fulfillmentLabels[value] ?? _fallback(value);
}

String labelPayment(String? value) => paymentLabels[value] ?? _fallback(value);

String labelPaymentProofReview(String? value) =>
    paymentProofReviewLabels[value] ?? _fallback(value);

String labelCancelledBy(String? value) =>
    cancelledByLabels[value] ?? _fallback(value);

bool isPickupFulfillment(String? value) => value == 'pickup';

bool isDeliveryFulfillment(String? value) =>
    value == 'local_same_day' || value == 'nationwide';

/// Customer-facing filter buckets for My orders.
enum OrderStatusGroup {
  active,
  completed,
  cancelled;

  String get label => switch (this) {
        active => 'Active',
        completed => 'Completed',
        cancelled => 'Cancelled',
      };

  String get apiValue => name;

  bool matches(String? status) {
    switch (this) {
      case OrderStatusGroup.active:
        return status != 'completed' && status != 'cancelled';
      case OrderStatusGroup.completed:
        return status == 'completed';
      case OrderStatusGroup.cancelled:
        return status == 'cancelled';
    }
  }
}

/// Timeline steps shown on order details (simplified customer journey).
List<({String key, String label})> orderTimelineSteps({
  required String? fulfillmentType,
}) {
  final third = isPickupFulfillment(fulfillmentType)
      ? (key: 'ready_for_pickup', label: 'Ready for pickup')
      : (key: 'out_for_delivery', label: 'Out for delivery');
  return [
    (key: 'pending', label: 'Pending'),
    (key: 'accepted', label: 'Accepted'),
    third,
    (key: 'completed', label: 'Delivered'),
  ];
}

/// Maps fine-grained backend status onto the customer timeline step index.
int orderTimelineIndex(String? status, {required String? fulfillmentType}) {
  switch (status) {
    case null:
    case '':
    case 'pending':
      return 0;
    case 'accepted':
    case 'awaiting_payment':
    case 'payment_submitted':
    case 'paid_confirmed':
    case 'preparing':
      return 1;
    case 'ready_for_pickup':
    case 'out_for_delivery':
      return 2;
    case 'completed':
      return 3;
    case 'cancelled':
      return -1;
    default:
      return 0;
  }
}

/// Short platform order number from `public_id` (first 8 chars of the UUID
/// string, with hyphens — same as admin `public_id.slice(0, 8)` /
/// backend `str(public_id)[:8]`).
///
/// Example: `02248330-1b5e-4756-a71f-f02605a5467a` → `#02248330`.
String formatOrderNumber(String? publicId) {
  final raw = (publicId ?? '').trim();
  if (raw.isEmpty) return '';
  final short = raw.length > 8 ? raw.substring(0, 8) : raw;
  return '#$short';
}

/// Home product list channel chips: All / In-store / Ecommerce.
enum ProductChannelFilter {
  all,
  inStore,
  ecommerce;

  String get label => switch (this) {
        all => 'All',
        inStore => 'In-store',
        ecommerce => 'Ecommerce',
      };

  bool matches({required bool showInStore, required bool showOnline}) =>
      switch (this) {
        all => true,
        inStore => showInStore,
        ecommerce => showOnline,
      };
}

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
