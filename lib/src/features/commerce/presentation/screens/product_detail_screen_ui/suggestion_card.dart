part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.product,
    required this.onTap,
  });

  final Map<String, dynamic> product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final discountPercent =
        _discountPercent(product['effective_discount_percent']);
    final hasDiscount = product['has_discount'] == true &&
        discountPercent != null &&
        discountPercent > 0;
    final imageUrl = product['image_url']?.toString();
    final price = formatRs(
      product['effective_price'] ?? product['base_price'],
    );
    final discountLabel = hasDiscount
        ? _formatDiscount(product['effective_discount_percent'])
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.md,
        child: Ink(
          width: 128.w,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppBorders.md,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: ColoredBox(
                        color: cs.surfaceContainerHighest,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Icon(
                                Icons.image_outlined,
                                color: cs.onSurfaceVariant,
                              ),
                      ),
                    ),
                    if (discountLabel != null)
                      Positioned(
                        left: 6.w,
                        bottom: 6.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.appColors.deal,
                            borderRadius: AppBorders.full,
                          ),
                          child: Text(
                            discountLabel,
                            style: tt.labelSmall?.copyWith(
                              color: context.appColors.onDeal,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelLarge?.copyWith(
                        color:
                            hasDiscount ? context.appColors.deal : cs.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
