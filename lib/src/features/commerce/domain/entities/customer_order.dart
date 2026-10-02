import 'package:aajhee/src/utils/api_value_parsers.dart';

/// One line as the orders list summarizes it.
class OrderSummaryLine {
  const OrderSummaryLine({
    required this.productName,
    required this.quantity,
  });

  final String productName;
  final int quantity;

  factory OrderSummaryLine.fromJson(Map<String, dynamic> json) {
    return OrderSummaryLine(
      productName: _text(json['product_name']),
      quantity: parseApiInt(json['quantity'], fallback: 1),
    );
  }
}

/// An order row on My orders.
class OrderSummary {
  const OrderSummary({
    required this.publicId,
    required this.status,
    required this.businessName,
    required this.total,
    required this.placedAt,
    required this.fulfillmentType,
    required this.paymentMethod,
    required this.lines,
  });

  final String publicId;
  final String status;
  final String businessName;
  final String total;
  final String placedAt;
  final String fulfillmentType;
  final String paymentMethod;
  final List<OrderSummaryLine> lines;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final lines = <OrderSummaryLine>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          lines.add(
            OrderSummaryLine.fromJson(Map<String, dynamic>.from(item)),
          );
        } else {
          lines.add(const OrderSummaryLine(productName: '', quantity: 1));
        }
      }
    }
    return OrderSummary(
      publicId: _text(json['public_id']),
      status: _text(json['status']),
      businessName: _text(json['business_name']),
      total: _text(json['total']),
      placedAt: _text(json['placed_at']),
      fulfillmentType: _text(json['fulfillment_type']),
      paymentMethod: _text(json['payment_method']),
      lines: lines,
    );
  }
}

/// One line on the order detail screen.
class OrderLine {
  const OrderLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.lineTotal,
    required this.imageUrl,
    required this.canReview,
    required this.reviewRating,
  });

  final int? id;
  final int? productId;
  final String productName;
  final int quantity;
  final String lineTotal;
  final String? imageUrl;
  final bool canReview;
  final int? reviewRating;

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    final review = json['review'];
    int? rating;
    if (review is Map) {
      final raw = review['rating'];
      rating = raw is int ? raw : int.tryParse('${raw ?? ''}');
    }
    return OrderLine(
      id: parseApiNullableInt(json['id']),
      productId: parseApiNullableInt(json['product_id']),
      productName: _text(json['product_name']),
      quantity: parseApiInt(json['quantity'], fallback: 1),
      lineTotal: _text(json['line_total']),
      imageUrl: _imageUrl(json),
      canReview: json['can_review'] == true,
      reviewRating: rating,
    );
  }
}

class OrderPaymentProof {
  const OrderPaymentProof({
    required this.reviewStatus,
    required this.note,
    required this.reviewNote,
    required this.submittedAt,
    required this.fileUrl,
  });

  final String reviewStatus;
  final String note;
  final String reviewNote;
  final String submittedAt;
  final String? fileUrl;

  factory OrderPaymentProof.fromJson(Map<String, dynamic> json) {
    final file = _text(json['file_url']);
    return OrderPaymentProof(
      reviewStatus: _text(json['review_status']),
      note: _text(json['note']),
      reviewNote: _text(json['review_note']),
      submittedAt: _text(json['submitted_at']),
      fileUrl: file.isEmpty ? null : file,
    );
  }
}

/// The order detail screen.
class OrderDetail {
  const OrderDetail({
    required this.publicId,
    required this.status,
    required this.businessName,
    required this.branchName,
    required this.fulfillmentType,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.customerPhone,
    required this.customerNotes,
    required this.deliveryFee,
    required this.deliveryAddressText,
    required this.deliveryHouseNumber,
    required this.deliveryLandmark,
    required this.promisedBy,
    required this.paymentInstructions,
    required this.bankTransferInstructions,
    required this.placedAt,
    required this.subtotal,
    required this.total,
    required this.lines,
    required this.paymentProofs,
    required this.cancelledBy,
    required this.cancelReason,
    required this.cancelledAt,
    required this.canCustomerCancel,
    required this.customerCancelAllowed,
    required this.customerCancelUntil,
    required this.storeWhatsapp,
    required this.storePhone,
  });

  final String publicId;
  final String status;
  final String businessName;
  final String branchName;
  final String fulfillmentType;
  final String paymentMethod;
  final String paymentStatus;
  final String customerPhone;
  final String customerNotes;
  final String deliveryFee;
  final String deliveryAddressText;
  final String deliveryHouseNumber;
  final String deliveryLandmark;
  final String promisedBy;
  final String paymentInstructions;
  final String bankTransferInstructions;
  final String placedAt;
  final String subtotal;
  final String total;
  final List<OrderLine> lines;
  final List<OrderPaymentProof> paymentProofs;
  final String cancelledBy;
  final String cancelReason;
  final String cancelledAt;
  final bool canCustomerCancel;

  /// Null unless the API sent an explicit true or false.
  final bool? customerCancelAllowed;
  final String customerCancelUntil;
  final String storeWhatsapp;
  final String storePhone;

  String get storeContact =>
      storeWhatsapp.isNotEmpty ? storeWhatsapp : storePhone;

  String get paymentInstructionsText => paymentInstructions.isNotEmpty
      ? paymentInstructions
      : bankTransferInstructions;

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final snapshot = json['delivery_snapshot'];
    final promised = snapshot is Map ? _text(snapshot['promised_by']) : '';
    return OrderDetail(
      publicId: _text(json['public_id']),
      status: _text(json['status']),
      businessName: _text(json['business_name']),
      branchName: _text(json['branch_name']),
      fulfillmentType: _text(json['fulfillment_type']),
      paymentMethod: _text(json['payment_method']),
      paymentStatus: _text(json['payment_status']),
      customerPhone: _text(json['customer_phone']),
      customerNotes: _text(json['customer_notes']),
      deliveryFee: _text(json['delivery_fee']),
      deliveryAddressText: _text(json['delivery_address_text']),
      deliveryHouseNumber: _text(json['delivery_house_number']),
      deliveryLandmark: _text(json['delivery_landmark']),
      promisedBy: promised,
      paymentInstructions: _text(json['payment_instructions']),
      bankTransferInstructions: _text(json['bank_transfer_instructions']),
      placedAt: _text(json['placed_at']),
      subtotal: _text(json['subtotal']),
      total: _text(json['total']),
      lines: _maps(json['items']).map(OrderLine.fromJson).toList(),
      paymentProofs:
          _maps(json['payment_proofs']).map(OrderPaymentProof.fromJson).toList(),
      cancelledBy: _text(json['cancelled_by']),
      cancelReason: _text(json['cancel_reason']),
      cancelledAt: _text(json['cancelled_at']),
      canCustomerCancel: json['can_customer_cancel'] == true,
      customerCancelAllowed: _explicitBool(json['customer_cancel_allowed']),
      customerCancelUntil: _text(json['customer_cancel_until']),
      storeWhatsapp: _text(json['store_whatsapp']),
      storePhone: _text(json['store_phone']),
    );
  }
}

String _text(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

bool? _explicitBool(dynamic value) {
  if (value == true) return true;
  if (value == false) return false;
  return null;
}

List<Map<String, dynamic>> _maps(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map<dynamic, dynamic>>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String? _imageUrl(Map<String, dynamic> json) {
  for (final key in [
    'image_url',
    'product_image_url',
    'thumbnail_url',
    'product_image',
  ]) {
    final value = _text(json[key]);
    if (value.isNotEmpty) return value;
  }
  final product = json['product'];
  if (product is Map) {
    final value = _text(product['image_url']);
    if (value.isNotEmpty) return value;
  }
  return null;
}
