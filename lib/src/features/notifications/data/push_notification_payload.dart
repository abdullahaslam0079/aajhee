import 'dart:convert';

/// Canonical FCM / inbox `data` keys used across Flutter + backend.
abstract final class PushDataKeys {
  PushDataKeys._();

  static const type = 'type';
  static const notificationId = 'notification_id';
  static const orderPublicId = 'order_public_id';
  static const businessId = 'business_id';
  static const branchId = 'branch_id';
  static const route = 'route';
}

/// Notification types that should refresh commerce order UI.
const orderRelatedPushTypes = {
  'order_status_changed',
  'order_rate_prompt',
  'business_new_order',
  'business_payment_proof',
};

bool isOrderRelatedPush(Map<String, dynamic> data) {
  final type = data[PushDataKeys.type]?.toString();
  if (type != null && orderRelatedPushTypes.contains(type)) return true;
  return orderPublicIdFromPushData(data) != null;
}

String? orderPublicIdFromPushData(Map<String, dynamic> data) {
  final raw = data[PushDataKeys.orderPublicId] ??
      data['order_id'] ??
      data['public_id'];
  final value = raw?.toString().trim() ?? '';
  if (value.isEmpty) return null;
  // Ignore numeric legacy ids — order routes expect UUID.
  if (int.tryParse(value) != null) return null;
  return value;
}

String? productRouteFromPushData(Map<String, dynamic> data) {
  final route = data[PushDataKeys.route]?.toString().trim();
  if (route != null && route.startsWith('/products/')) return route;
  final productId = data['product_id']?.toString().trim();
  if (productId != null && productId.isNotEmpty) {
    return '/products/$productId';
  }
  return null;
}

/// Encode a compact payload for local-notification taps.
///
/// Normalizes UUID order aliases (`order_id` / `public_id`) into
/// [PushDataKeys.orderPublicId] so foreground taps keep order deep links.
String encodeLocalNotificationPayload(Map<String, dynamic> data) {
  final compact = <String, String>{};
  for (final key in [
    PushDataKeys.type,
    PushDataKeys.notificationId,
    PushDataKeys.orderPublicId,
    PushDataKeys.businessId,
    PushDataKeys.branchId,
    PushDataKeys.route,
    'product_id',
  ]) {
    final value = data[key];
    if (value != null && value.toString().isNotEmpty) {
      compact[key] = value.toString();
    }
  }

  final orderPublicId = orderPublicIdFromPushData(data);
  if (orderPublicId != null) {
    compact[PushDataKeys.orderPublicId] = orderPublicId;
  }

  return jsonEncode(compact);
}

Map<String, dynamic> decodeLocalNotificationPayload(String? payload) {
  if (payload == null || payload.isEmpty) return const {};
  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    // Legacy: jsonDecode('12') yields a number, not a Map.
    if (decoded is num) {
      return {PushDataKeys.notificationId: decoded.toString()};
    }
  } catch (_) {
    // Fall through to plain int parse.
  }
  final id = int.tryParse(payload);
  if (id != null) {
    return {PushDataKeys.notificationId: id.toString()};
  }
  return const {};
}
