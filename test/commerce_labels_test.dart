import 'package:aajhee/src/features/commerce/domain/commerce_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('requiresPaymentProof', () {
    test('is true for bank transfer, stripe, and jazzcash', () {
      expect(requiresPaymentProof('bank_transfer'), isTrue);
      expect(requiresPaymentProof('stripe'), isTrue);
      expect(requiresPaymentProof('jazzcash'), isTrue);
    });

    test('is false for cash methods and null', () {
      expect(requiresPaymentProof('cash_on_delivery'), isFalse);
      expect(requiresPaymentProof('cash_on_pickup'), isFalse);
      expect(requiresPaymentProof(null), isFalse);
      expect(requiresPaymentProof(''), isFalse);
    });
  });

  group('formatOrderNumber', () {
    test('shortens uuid to first 8 chars of public_id', () {
      expect(
        formatOrderNumber('02248330-1b5e-4756-a71f-f02605a5467a'),
        '#02248330',
      );
    });

    test('returns empty for blank', () {
      expect(formatOrderNumber(null), '');
      expect(formatOrderNumber(''), '');
    });
  });

  group('labelPayment', () {
    test('maps known methods', () {
      expect(labelPayment('stripe'), 'Card');
      expect(labelPayment('jazzcash'), 'JazzCash');
      expect(labelPayment('bank_transfer'), 'Bank transfer');
    });
  });
}
