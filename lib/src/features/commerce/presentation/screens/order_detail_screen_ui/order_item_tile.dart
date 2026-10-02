part of 'package:aajhee/src/features/commerce/presentation/screens/order_detail_screen.dart';

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({
    required this.item,
    this.imageUrl,
    this.orderStatus,
    this.onRate,
  });

  final OrderLine item;
  final String? imageUrl;
  final String? orderStatus;
  final VoidCallback? onRate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final name = item.productName.isNotEmpty ? item.productName : 'Product';
    final qty = item.quantity;
    final lineTotal = item.lineTotal;
    final productId = item.productId;
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    final resolvedImage = (imageUrl ?? '').trim();
    final reviewRating = item.reviewRating;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: productId == null
            ? null
            : () => context.push(
                  AppRoutes.productDetail('$productId'),
                ),
        borderRadius: AppBorders.md,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppBorders.md,
                child: SizedBox(
                  width: 56.w,
                  height: 56.w,
                  child: resolvedImage.isNotEmpty
                      ? Image.network(
                          resolvedImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ItemImageFallback(
                            initial: initial,
                            colorScheme: cs,
                            textTheme: tt,
                          ),
                        )
                      : _ItemImageFallback(
                          initial: initial,
                          colorScheme: cs,
                          textTheme: tt,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Qty $qty · Rs $lineTotal',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (reviewRating != null) ...[
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < reviewRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 16.sp,
                              color: const Color(0xFFE6A817),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Your rating',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ] else if (onRate != null) ...[
                      SizedBox(height: 8.h),
                      OutlinedButton.icon(
                        onPressed: onRate,
                        icon: Icon(Icons.star_outline_rounded, size: 18.sp),
                        label: const Text('Rate product'),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                        ),
                      ),
                    ] else if (productId != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'View product',
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (productId != null)
                Icon(Icons.chevron_right_rounded, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }
}
