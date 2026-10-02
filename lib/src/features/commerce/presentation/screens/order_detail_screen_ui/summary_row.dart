part of 'package:aajhee/src/features/commerce/presentation/screens/order_detail_screen.dart';

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          label,
          style: (emphasize ? tt.titleSmall : tt.bodyMedium)?.copyWith(
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: (emphasize ? tt.titleSmall : tt.bodyMedium)?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
