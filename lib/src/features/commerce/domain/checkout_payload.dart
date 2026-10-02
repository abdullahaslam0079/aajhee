import 'package:aajhee/src/features/commerce/domain/commerce_labels.dart';
import 'package:aajhee/src/features/commerce/domain/pakistani_phone.dart';

/// Inputs for one store group on `POST /api/checkout/place`.
class CheckoutGroupDraft {
  const CheckoutGroupDraft({
    required this.branchId,
    required this.itemIds,
    required this.fulfillmentType,
    required this.paymentMethod,
    required this.houseNumber,
    required this.landmark,
    required this.customerPhone,
    this.deliveryAddressText = '',
    this.addressInstructions = '',
    this.notes = '',
  });

  final int branchId;
  final List<int> itemIds;
  final String fulfillmentType;
  final String paymentMethod;
  final String houseNumber;
  final String landmark;
  final String customerPhone;
  final String deliveryAddressText;
  final String addressInstructions;
  final String notes;
}

/// Builds the JSON object the checkout API expects for one store.
Map<String, dynamic> buildCheckoutGroupPayload(CheckoutGroupDraft draft) {
  final isDelivery = isDeliveryFulfillment(draft.fulfillmentType);
  final customerNotes = <String>[
    if (isDelivery) draft.addressInstructions.trim(),
    if (draft.notes.trim().isNotEmpty) draft.notes.trim(),
  ].where((line) => line.isNotEmpty).join('\n');

  return {
    'branch_id': draft.branchId,
    'item_ids': draft.itemIds,
    'fulfillment_type': draft.fulfillmentType,
    'payment_method': draft.paymentMethod,
    if (isDelivery) 'delivery_address_text': draft.deliveryAddressText,
    'delivery_house_number': draft.houseNumber,
    'delivery_landmark': draft.landmark,
    'customer_phone': draft.customerPhone,
    'customer_notes': customerNotes,
  };
}

/// One store group as the place-order button checks it.
class CheckoutPlaceGroup {
  const CheckoutPlaceGroup({
    required this.fulfillmentType,
    required this.paymentMethod,
    required this.storeName,
    required this.hasPaymentProof,
  });

  final String fulfillmentType;
  final String paymentMethod;
  final String storeName;
  final bool hasPaymentProof;
}

/// First reason [CheckoutScreenController] should refuse to place the order.
///
/// Returns null when the draft is ready. Messages match the checkout screen.
String? checkoutPlaceError({
  required String phone,
  required bool hasDeliveryAddress,
  required String houseNumber,
  required List<CheckoutPlaceGroup> groups,
}) {
  final phoneError = validatePakistaniMobile(phone);
  if (phoneError != null) return phoneError;

  final trimmedHouseNumber = houseNumber.trim();
  for (final group in groups) {
    if (group.fulfillmentType.isEmpty || group.paymentMethod.isEmpty) {
      return 'Choose delivery and payment for every store.';
    }
    if (isDeliveryFulfillment(group.fulfillmentType)) {
      if (!hasDeliveryAddress) {
        return 'Add a delivery address to continue.';
      }
      if (trimmedHouseNumber.isEmpty) {
        return 'Enter your house / flat number.';
      }
    }
    if (requiresPaymentProof(group.paymentMethod) && !group.hasPaymentProof) {
      return 'Upload a payment receipt for ${group.storeName}.';
    }
  }
  return null;
}
