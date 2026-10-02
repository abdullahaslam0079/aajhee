part of 'package:aajhee/src/features/commerce/presentation/screens/checkout_screen.dart';

class _CheckoutItemRow extends StatelessWidget {
  const _CheckoutItemRow({required this.item});

  final CartLine item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final product = item.product;
    final name = product.displayName;
    final imageUrl = product.imageUrl;
    final qty = item.quantity;
    final lineTotal = item.displayLineTotal;

    return Row(
      children: [
        ClipRRect(
          borderRadius: AppBorders.sm,
          child: SizedBox(
            width: 56.w,
            height: 56.w,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : ColoredBox(
                    color: cs.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_outlined,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Qty $qty',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Text(
          'Rs $lineTotal',
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
