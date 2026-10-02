part of 'package:aajhee/src/features/commerce/presentation/screens/checkout_screen.dart';

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String _money(double value) => value.toStringAsFixed(2);
