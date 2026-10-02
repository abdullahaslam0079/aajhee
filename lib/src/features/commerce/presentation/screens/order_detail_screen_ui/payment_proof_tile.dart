part of 'package:aajhee/src/features/commerce/presentation/screens/order_detail_screen.dart';

class _PaymentProofTile extends StatelessWidget {
  const _PaymentProofTile({required this.proof});

  final OrderPaymentProof proof;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final status = proof.reviewStatus;
    final note = proof.note;
    final reviewNote = proof.reviewNote;
    final submittedAt = proof.submittedAt;
    final fileUrl = resolveMediaUrl(proof.fileUrl);
    final statusColor = switch (status) {
      'accepted' => context.appColors.success,
      'rejected' => cs.error,
      _ => cs.onSurfaceVariant,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: fileUrl == null
              ? null
              : () => launchUrl(
                    Uri.parse(fileUrl),
                    mode: LaunchMode.externalApplication,
                  ),
          icon: Icon(Icons.receipt_long_outlined, color: cs.primary),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelPaymentProofReview(status),
                style: tt.titleSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (submittedAt.isNotEmpty)
                Text(
                  'Submitted ${formatCommerceDateTime(submittedAt)}',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (note.isNotEmpty)
                Text(
                  'Note: $note',
                  style: tt.bodySmall?.copyWith(color: cs.onSurface),
                ),
              if (reviewNote.isNotEmpty)
                Text(
                  'Shop: $reviewNote',
                  style: tt.bodySmall?.copyWith(color: cs.onSurface),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
