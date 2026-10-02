import 'package:aajhee/src/features/commerce/domain/checkout_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('delivery checkout includes the address and combined notes', () {
    final payload = buildCheckoutGroupPayload(
      const CheckoutGroupDraft(
        branchId: 9,
        itemIds: [3, 4],
        fulfillmentType: 'local_same_day',
        paymentMethod: 'cash_on_delivery',
        houseNumber: '12-B',
        landmark: 'Near the masjid',
        customerPhone: '+923001234567',
        deliveryAddressText: 'House 12, Lahore',
        addressInstructions: 'Ring the bell',
        notes: 'Leave at the gate',
      ),
    );

    expect(payload['branch_id'], 9);
    expect(payload['item_ids'], [3, 4]);
    expect(payload['fulfillment_type'], 'local_same_day');
    expect(payload['payment_method'], 'cash_on_delivery');
    expect(payload['delivery_address_text'], 'House 12, Lahore');
    expect(payload['delivery_house_number'], '12-B');
    expect(payload['customer_phone'], '+923001234567');
    expect(payload['customer_notes'], 'Ring the bell\nLeave at the gate');
  });

  test('pickup checkout omits the delivery address text', () {
    final payload = buildCheckoutGroupPayload(
      const CheckoutGroupDraft(
        branchId: 2,
        itemIds: [8],
        fulfillmentType: 'pickup',
        paymentMethod: 'cash_on_pickup',
        houseNumber: '',
        landmark: '',
        customerPhone: '+923001234567',
        deliveryAddressText: 'Should not be sent',
        notes: '',
      ),
    );

    expect(payload.containsKey('delivery_address_text'), isFalse);
    expect(payload['customer_notes'], '');
    expect(payload['payment_method'], 'cash_on_pickup');
  });

  test('place order reports the first missing requirement', () {
    expect(
      checkoutPlaceError(
        phone: '123',
        hasDeliveryAddress: true,
        houseNumber: '12',
        groups: const [
          CheckoutPlaceGroup(
            fulfillmentType: 'local_same_day',
            paymentMethod: 'cash_on_delivery',
            storeName: 'Atta Shop',
            hasPaymentProof: false,
          ),
        ],
      ),
      'Enter a Pakistani mobile (03XX-XXXXXXX or +92 3XX XXXXXXX)',
    );

    expect(
      checkoutPlaceError(
        phone: '03001234567',
        hasDeliveryAddress: false,
        houseNumber: '12',
        groups: const [
          CheckoutPlaceGroup(
            fulfillmentType: 'local_same_day',
            paymentMethod: 'cash_on_delivery',
            storeName: 'Atta Shop',
            hasPaymentProof: false,
          ),
        ],
      ),
      'Add a delivery address to continue.',
    );

    expect(
      checkoutPlaceError(
        phone: '03001234567',
        hasDeliveryAddress: true,
        houseNumber: ' ',
        groups: const [
          CheckoutPlaceGroup(
            fulfillmentType: 'nationwide',
            paymentMethod: 'cash_on_delivery',
            storeName: 'Atta Shop',
            hasPaymentProof: false,
          ),
        ],
      ),
      'Enter your house / flat number.',
    );

    expect(
      checkoutPlaceError(
        phone: '03001234567',
        hasDeliveryAddress: true,
        houseNumber: '12',
        groups: const [
          CheckoutPlaceGroup(
            fulfillmentType: 'pickup',
            paymentMethod: 'bank_transfer',
            storeName: 'Atta Shop',
            hasPaymentProof: false,
          ),
        ],
      ),
      'Upload a payment receipt for Atta Shop.',
    );
  });

  test('pickup cash can be placed without an address or receipt', () {
    expect(
      checkoutPlaceError(
        phone: '03001234567',
        hasDeliveryAddress: false,
        houseNumber: '',
        groups: const [
          CheckoutPlaceGroup(
            fulfillmentType: 'pickup',
            paymentMethod: 'cash_on_pickup',
            storeName: 'Atta Shop',
            hasPaymentProof: false,
          ),
        ],
      ),
      isNull,
    );
  });
}
