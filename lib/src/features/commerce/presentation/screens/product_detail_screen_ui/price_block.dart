part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.price,
    required this.emphasize,
    this.basePrice,
  });

  final String price;
  final String? basePrice;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final deal = context.appColors.deal;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          price,
          style: tt.headlineSmall?.copyWith(
            color: emphasize ? deal : cs.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            height: 1.1,
          ),
        ),
        if (basePrice != null && basePrice!.isNotEmpty) ...[
          SizedBox(width: 10.w),
          Text(
            basePrice!,
            style: tt.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
