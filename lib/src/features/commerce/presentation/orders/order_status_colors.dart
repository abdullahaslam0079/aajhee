import 'package:flutter/material.dart';
import 'package:aajhee/src/extensions/context_extension.dart';

(Color, Color) orderStatusColors(BuildContext context, String? status) {
  final cs = Theme.of(context).colorScheme;
  final appColors = context.appColors;
  return switch (status) {
    'completed' => (
        appColors.success,
        appColors.successContainer ??
            appColors.success.withValues(alpha: 0.12),
      ),
    'cancelled' => (cs.error, cs.errorContainer),
    'pending' ||
    'accepted' ||
    'awaiting_payment' ||
    'payment_submitted' ||
    'paid_confirmed' ||
    'preparing' ||
    'ready_for_pickup' ||
    'out_for_delivery' => (
        appColors.warning,
        appColors.warningContainer ??
            appColors.warning.withValues(alpha: 0.12),
      ),
    _ => (cs.onSurfaceVariant, cs.surfaceContainerHighest),
  };
}
