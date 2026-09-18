import 'package:aajhee/src/features/home/data/models/offer_model.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_payment_preview.dart';
import 'package:aajhee/src/features/offerScanner/presentation/widgets/offer_payment_summary_card.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class OfferCounterConfirmationSheet extends StatefulWidget {
  const OfferCounterConfirmationSheet({
    super.key,
    required this.offer,
    required this.branchName,
    required this.branchAddress,
    required this.payment,
    required this.needsBillAmount,
    required this.isProcessing,
    required this.onConfirm,
    required this.onBillAmountSubmit,
    this.errorMessage,
  });

  final OfferModel offer;
  final String branchName;
  final String branchAddress;
  final OfferPaymentPreview payment;
  final bool needsBillAmount;
  final bool isProcessing;
  final VoidCallback onConfirm;
  final ValueChanged<String> onBillAmountSubmit;
  final String? errorMessage;

  static Future<void> show(
    BuildContext context, {
    required OfferModel offer,
    required String branchName,
    required String branchAddress,
    required OfferPaymentPreview payment,
    required bool needsBillAmount,
    required bool isProcessing,
    required VoidCallback onConfirm,
    required ValueChanged<String> onBillAmountSubmit,
    String? errorMessage,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: !isProcessing,
      enableDrag: !isProcessing,
      builder: (_) => OfferCounterConfirmationSheet(
        offer: offer,
        branchName: branchName,
        branchAddress: branchAddress,
        payment: payment,
        needsBillAmount: needsBillAmount,
        isProcessing: isProcessing,
        onConfirm: onConfirm,
        onBillAmountSubmit: onBillAmountSubmit,
        errorMessage: errorMessage,
      ),
    );
  }

  @override
  State<OfferCounterConfirmationSheet> createState() =>
      _OfferCounterConfirmationSheetState();
}

class _OfferCounterConfirmationSheetState
    extends State<OfferCounterConfirmationSheet> {
  final _billController = TextEditingController();
  OfferPaymentPreview? _localPayment;

  @override
  void initState() {
    super.initState();
    _localPayment = widget.payment;
  }

  @override
  void didUpdateWidget(covariant OfferCounterConfirmationSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payment != widget.payment) {
      _localPayment = widget.payment;
    }
  }

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.65);
    final payment = _localPayment ?? widget.payment;
    final showConfirm = !widget.needsBillAmount && payment.isComplete;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg.w,
        right: AppSpacing.lg.w,
        top: AppSpacing.md.h,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: AppBorders.full,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            'Show this at the counter',
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: AppSpacing.xxs.h),
          Text(
            widget.offer.title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.xxs.h),
          Text(
            '${widget.branchName} · ${widget.branchAddress}',
            style: tt.bodySmall?.copyWith(color: muted),
          ),
          SizedBox(height: AppSpacing.lg.h),
          if (widget.needsBillAmount) ...[
            Text(
              'Enter your bill total',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppSpacing.xs.h),
            TextField(
              controller: _billController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '€ ',
                hintText: '0.00',
                border: OutlineInputBorder(borderRadius: AppBorders.sm),
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            FilledButton(
              onPressed: widget.isProcessing
                  ? null
                  : () => widget.onBillAmountSubmit(_billController.text),
              child: widget.isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Calculate payment'),
            ),
          ] else ...[
            OfferPaymentSummaryCard(payment: payment),
          ],
          if (widget.errorMessage?.isNotEmpty == true) ...[
            SizedBox(height: AppSpacing.sm.h),
            Text(
              widget.errorMessage!,
              style: tt.bodySmall?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (showConfirm) ...[
            SizedBox(height: AppSpacing.lg.h),
            FilledButton(
              onPressed: widget.isProcessing ? null : widget.onConfirm,
              child: widget.isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Avail offer'),
            ),
          ],
          SizedBox(height: AppSpacing.sm.h),
          Text(
            'The cashier can read the amount from your phone. No business app needed.',
            style: tt.bodySmall?.copyWith(color: muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
