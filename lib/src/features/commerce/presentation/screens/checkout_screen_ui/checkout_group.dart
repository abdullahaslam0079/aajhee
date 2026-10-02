part of 'package:aajhee/src/features/commerce/presentation/screens/checkout_screen.dart';

class _CheckoutGroup {
  _CheckoutGroup({
    required this.branchId,
    required this.items,
    required this.preview,
    required this.fulfillmentType,
    required this.paymentMethod,
  });

  final int branchId;
  final List<CartLine> items;
  final CheckoutPreview preview;
  String fulfillmentType;
  String paymentMethod;

  List<CheckoutFulfillmentOption> get options => preview.options;

  CheckoutPaymentMethods get payments => preview.paymentMethods;

  CheckoutFulfillmentOption? get selectedOption {
    for (final option in options) {
      if (option.fulfillmentType == fulfillmentType) return option;
    }
    return options.isEmpty ? null : options.first;
  }

  String get storeName {
    for (final item in items) {
      final name = item.product.businessName ?? '';
      if (name.isNotEmpty) return name;
    }
    return 'Store';
  }

  double get itemsSubtotal {
    var sum = 0.0;
    for (final item in items) {
      sum += _toDouble(item.displayLineTotal);
    }
    return sum;
  }

  double get deliveryFee => selectedOption?.fee ?? 0;

  double get total => itemsSubtotal + deliveryFee;

  List<String> availablePaymentMethods() {
    final methods = <String>[];
    if (fulfillmentType == 'pickup' && payments.cashOnPickup) {
      methods.add('cash_on_pickup');
    }
    if (fulfillmentType != 'pickup' && payments.cashOnDelivery) {
      methods.add('cash_on_delivery');
    }
    if (payments.bankTransfer) methods.add('bank_transfer');
    if (payments.stripe) methods.add('stripe');
    if (payments.jazzcash) methods.add('jazzcash');
    return methods;
  }
}
