part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

double? _discountPercent(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

String? _formatDiscount(dynamic value) {
  final parsed = _discountPercent(value);
  if (parsed == null || parsed <= 0) return null;
  final label = parsed == parsed.roundToDouble()
      ? '${parsed.toInt()}%'
      : '${parsed.toStringAsFixed(0)}%';
  return '$label off';
}
