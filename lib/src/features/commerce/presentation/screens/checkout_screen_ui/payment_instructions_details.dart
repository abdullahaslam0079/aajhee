part of 'package:aajhee/src/features/commerce/presentation/screens/checkout_screen.dart';

class _PaymentInstructionsDetails extends StatelessWidget {
  const _PaymentInstructionsDetails({
    required this.method,
    required this.payments,
  });

  final String method;
  final CheckoutPaymentMethods payments;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final title = switch (method) {
      'stripe' => 'Card payment details',
      'jazzcash' => 'JazzCash details',
      _ => 'Bank transfer details',
    };
    final instructions = payments.instructionsFor(method);
    final iban = method == 'bank_transfer' ? payments.iban : null;
    final accountName = method == 'bank_transfer' ? payments.accountName : null;
    final bankName = method == 'bank_transfer' ? payments.bankName : null;

    if (iban == null &&
        accountName == null &&
        bankName == null &&
        (instructions == null || instructions.isEmpty)) {
      return Padding(
        padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
        child: Text(
          'After the shop accepts your order, pay and upload your transaction screenshot.',
          style:
              tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 4.h, bottom: 4.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: AppBorders.md,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          if (bankName != null) _BankLine(label: 'Bank', value: bankName),
          if (accountName != null)
            _BankLine(label: 'Account name', value: accountName),
          if (iban != null) _BankLine(label: 'IBAN', value: iban),
          if (instructions != null && instructions.isNotEmpty) ...[
            if (iban != null || accountName != null || bankName != null)
              SizedBox(height: 6.h),
            Text(
              instructions,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
