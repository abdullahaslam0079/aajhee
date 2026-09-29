import 'package:flutter/material.dart';

extension NumExtension on num {
  // SizedBox generators
  Widget get kH => SizedBox(height: toDouble());
  Widget get kW => SizedBox(width: toDouble());

  // BorderRadius helpers
  BorderRadius get radius => BorderRadius.circular(toDouble());

  // Duration helpers
  Duration get ms => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());

  /// PKR amount with thousands separators, e.g. `Rs 2,620` or `Rs 2,620.50`.
  String get asRs {
    final isWhole = this % 1 == 0;
    final raw = isWhole ? toInt().toString() : toStringAsFixed(2);
    final parts = raw.split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      final fromEnd = intPart.length - i;
      buffer.write(intPart[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
    }
    if (parts.length > 1) buffer.write('.${parts[1]}');
    return 'Rs $buffer';
  }
}
