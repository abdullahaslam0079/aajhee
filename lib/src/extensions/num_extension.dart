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

  /// PKR amount with cents, e.g. `Rs 5.55`.
  String get asRs => 'Rs ${toStringAsFixed(2)}';
}
