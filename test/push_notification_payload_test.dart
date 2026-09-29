import 'package:aajhee/src/features/notifications/data/push_notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('push_notification_payload', () {
    test('extracts order_public_id and ignores numeric order_id', () {
      expect(
        orderPublicIdFromPushData({
          PushDataKeys.orderPublicId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        }),
        'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
      );
      expect(orderPublicIdFromPushData({'order_id': '42'}), isNull);
      expect(
        orderPublicIdFromPushData({'order_id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'}),
        'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
      );
    });

    test('detects order-related pushes', () {
      expect(
        isOrderRelatedPush({'type': 'order_status_changed'}),
        isTrue,
      );
      expect(
        isOrderRelatedPush({
          PushDataKeys.orderPublicId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        }),
        isTrue,
      );
      expect(isOrderRelatedPush({'type': 'favorited_business_new_offer'}), isFalse);
    });

    test('round-trips local notification payload', () {
      final encoded = encodeLocalNotificationPayload({
        PushDataKeys.type: 'order_status_changed',
        PushDataKeys.orderPublicId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        PushDataKeys.notificationId: 7,
      });
      final decoded = decodeLocalNotificationPayload(encoded);
      expect(decoded[PushDataKeys.type], 'order_status_changed');
      expect(
        decoded[PushDataKeys.orderPublicId],
        'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
      );
      expect(decodeLocalNotificationPayload('12')[PushDataKeys.notificationId], '12');
    });
  });
}
