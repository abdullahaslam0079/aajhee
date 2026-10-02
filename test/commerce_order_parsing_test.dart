import 'package:aajhee/src/features/commerce/domain/entities/checkout_preview.dart';
import 'package:aajhee/src/features/commerce/domain/entities/customer_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('order summary counts quantities and keeps a non-map line', () {
    final order = OrderSummary.fromJson({
      'public_id': '02248330-1b5e-4756-a71f-f02605a5467a',
      'status': 'pending',
      'business_name': 'Al-Madina',
      'total': 450,
      'placed_at': '2026-09-27T15:05:00Z',
      'fulfillment_type': 'pickup',
      'payment_method': 'cash_on_pickup',
      'items': [
        {'product_name': 'Atta', 'quantity': '2'},
        'not-a-line',
      ],
    });

    expect(order.publicId, '02248330-1b5e-4756-a71f-f02605a5467a');
    expect(order.businessName, 'Al-Madina');
    expect(order.total, '450');
    expect(order.lines, hasLength(2));
    expect(order.lines.first.productName, 'Atta');
    expect(order.lines.first.quantity, 2);
    expect(order.lines.last.quantity, 1);
    expect(
      order.lines.fold<int>(0, (sum, line) => sum + line.quantity),
      3,
    );
  });

  test('order detail reads the fields the screen shows', () {
    final order = OrderDetail.fromJson({
      'public_id': 'abc',
      'status': 'completed',
      'business_name': 'Store',
      'fulfillment_type': 'local_same_day',
      'payment_method': 'bank_transfer',
      'payment_instructions': 'Transfer before pickup',
      'bank_transfer_instructions': 'ignored when payment_instructions is set',
      'delivery_fee': '50',
      'delivery_snapshot': {'promised_by': '2026-09-27T18:00:00Z'},
      'can_customer_cancel': true,
      'customer_cancel_allowed': false,
      'customer_cancel_until': '2026-09-27T16:00:00Z',
      'store_whatsapp': '+923001234567',
      'items': [
        {
          'id': '9',
          'product_id': 4,
          'product_name': 'Rice',
          'quantity': 1,
          'line_total': '200',
          'can_review': true,
          'review': {'rating': 4},
          'product': {'image_url': 'https://cdn.example/rice.jpg'},
        },
      ],
      'payment_proofs': [
        {
          'review_status': 'accepted',
          'note': 'paid',
          'file_url': 'https://cdn.example/receipt.jpg',
        },
      ],
    });

    expect(order.paymentInstructionsText, 'Transfer before pickup');
    expect(order.promisedBy, '2026-09-27T18:00:00Z');
    expect(order.canCustomerCancel, isTrue);
    expect(order.customerCancelAllowed, isFalse);
    expect(order.storeContact, '+923001234567');
    expect(order.lines.single.id, 9);
    expect(order.lines.single.canReview, isTrue);
    expect(order.lines.single.reviewRating, 4);
    expect(order.lines.single.imageUrl, 'https://cdn.example/rice.jpg');
    expect(order.paymentProofs.single.reviewStatus, 'accepted');
    expect(order.paymentProofs.single.fileUrl, 'https://cdn.example/receipt.jpg');
  });

  test('checkout preview keeps available options and bank details', () {
    final preview = CheckoutPreview.fromJson({
      'options': [
        {
          'available': false,
          'fulfillment_type': 'delivery',
          'fee': 80,
        },
        {
          'available': true,
          'fulfillment_type': 'pickup',
          'label': 'Collect',
          'fee': '0',
        },
      ],
      'payment_methods': {
        'cash_on_pickup': true,
        'bank_transfer': true,
        'bank_transfer_details': {
          'account_name': 'Aajhee Store',
          'iban': 'PK00TEST',
        },
        'bank_transfer_instructions': {'text': 'Send the receipt after paying.'},
        'stripe_instructions': 'Pay by card',
      },
    });

    expect(preview.options, hasLength(1));
    expect(preview.options.single.fulfillmentType, 'pickup');
    expect(preview.options.single.label, 'Collect');
    expect(preview.options.single.fee, 0);
    expect(preview.paymentMethods.cashOnPickup, isTrue);
    expect(preview.paymentMethods.cashOnDelivery, isFalse);
    expect(preview.paymentMethods.bankTransfer, isTrue);
    expect(preview.paymentMethods.iban, 'PK00TEST');
    expect(preview.paymentMethods.accountName, 'Aajhee Store');
    expect(
      preview.paymentMethods.instructionsFor('bank_transfer'),
      'Send the receipt after paying.',
    );
    expect(
      preview.paymentMethods.instructionsFor('stripe'),
      'Pay by card',
    );
  });
}
