part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

class _ProductRatingRow extends StatelessWidget {
  const _ProductRatingRow({required this.product});

  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final count = int.tryParse('${product['rating_count'] ?? 0}') ?? 0;
    final avg = double.tryParse('${product['rating_avg'] ?? 0}') ?? 0.0;
    if (count <= 0) {
      return Text(
        'No ratings yet',
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      );
    }
    final filled = avg.round().clamp(0, 5);
    return Row(
      children: [
        ...List.generate(
          5,
          (i) => Icon(
            i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18.sp,
            color: const Color(0xFFE6A817),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '${avg.toStringAsFixed(1)} ($count)',
          style: tt.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
