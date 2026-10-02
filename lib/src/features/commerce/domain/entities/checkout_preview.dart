/// One available fulfillment choice from `POST /api/checkout/preview`.
class CheckoutFulfillmentOption {
  const CheckoutFulfillmentOption({
    required this.fulfillmentType,
    required this.label,
    required this.fee,
  });

  final String fulfillmentType;
  final String label;
  final double fee;
}

/// Payment flags and the bank or wallet details the checkout screen shows.
class CheckoutPaymentMethods {
  const CheckoutPaymentMethods({
    this.cashOnPickup = false,
    this.cashOnDelivery = false,
    this.bankTransfer = false,
    this.stripe = false,
    this.jazzcash = false,
    this.iban,
    this.accountName,
    this.bankName,
    this.bankInstructions,
    this.stripeInstructions,
    this.jazzcashInstructions,
  });

  final bool cashOnPickup;
  final bool cashOnDelivery;
  final bool bankTransfer;
  final bool stripe;
  final bool jazzcash;
  final String? iban;
  final String? accountName;
  final String? bankName;
  final String? bankInstructions;
  final String? stripeInstructions;
  final String? jazzcashInstructions;

  String? instructionsFor(String method) {
    return switch (method) {
      'stripe' => stripeInstructions,
      'jazzcash' => jazzcashInstructions,
      _ => bankInstructions,
    };
  }

  factory CheckoutPaymentMethods.fromJson(Map<String, dynamic> json) {
    return CheckoutPaymentMethods(
      cashOnPickup: json['cash_on_pickup'] == true,
      cashOnDelivery: json['cash_on_delivery'] == true,
      bankTransfer: json['bank_transfer'] == true,
      stripe: json['stripe'] == true,
      jazzcash: json['jazzcash'] == true,
      iban: _bankField(json, 'iban') ??
          _bankField(json, 'account_iban') ??
          _bankField(json, 'bank_transfer_iban'),
      accountName: _bankField(json, 'account_name') ??
          _bankField(json, 'bank_account_name'),
      bankName: _bankField(json, 'bank_name') ?? _bankField(json, 'bank'),
      bankInstructions: _instructions(json, 'bank_transfer_instructions'),
      stripeInstructions: _instructions(json, 'stripe_instructions'),
      jazzcashInstructions: _instructions(json, 'jazzcash_instructions'),
    );
  }
}

class CheckoutPreview {
  const CheckoutPreview({
    required this.options,
    required this.paymentMethods,
  });

  final List<CheckoutFulfillmentOption> options;
  final CheckoutPaymentMethods paymentMethods;

  factory CheckoutPreview.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = <CheckoutFulfillmentOption>[];
    if (rawOptions is List) {
      for (final item in rawOptions) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        if (map['available'] != true) continue;
        options.add(
          CheckoutFulfillmentOption(
            fulfillmentType: _text(map['fulfillment_type']),
            label: _text(map['label']),
            fee: _fee(map['fee']),
          ),
        );
      }
    }
    final payments = json['payment_methods'];
    return CheckoutPreview(
      options: options,
      paymentMethods: payments is Map
          ? CheckoutPaymentMethods.fromJson(Map<String, dynamic>.from(payments))
          : const CheckoutPaymentMethods(),
    );
  }
}

String _text(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

double _fee(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String? _nonEmpty(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return text;
}

String? _bankField(Map<String, dynamic> payments, String key) {
  final direct = _nonEmpty(payments[key] ?? payments['bank_transfer_$key']);
  if (direct != null) return direct;

  final nested = payments['bank_transfer_details'];
  if (nested is Map) {
    final value = _nonEmpty(nested[key] ?? nested['bank_transfer_$key']);
    if (value != null) return value;
  }

  final instructions = payments['bank_transfer_instructions'];
  if (instructions is Map) {
    return _nonEmpty(instructions[key]);
  }
  return null;
}

String? _instructions(Map<String, dynamic> payments, String key) {
  final raw = payments[key];
  if (raw is String) return _nonEmpty(raw);
  if (raw is Map) {
    return _nonEmpty(raw['text'] ?? raw['instructions'] ?? raw['message']);
  }
  return null;
}
