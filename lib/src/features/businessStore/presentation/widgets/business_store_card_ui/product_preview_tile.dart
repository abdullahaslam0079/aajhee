part of 'package:aajhee/src/features/businessStore/presentation/widgets/business_store_card.dart';

class _ProductPreviewTile extends StatelessWidget {
  const _ProductPreviewTile({
    required this.product,
    required this.width,
    required this.imageSize,
  });

  final BranchTopProductModel product;
  final double width;
  final double imageSize;

  double get _displayPrice =>
      product.effectivePrice ??
      product.salePrice ??
      product.basePrice;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final url = product.imageUrl;
    final priceLabel = formatRs(_displayPrice);
    final name = product.name.trim().isEmpty ? 'Product' : product.name.trim();

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: imageSize,
            height: imageSize,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFFF3F1F1),
                borderRadius: AppBorders.sm,
              ),
              child: ClipRRect(
                borderRadius: AppBorders.sm,
                child: url != null && url.isNotEmpty
                    ? CommonImage(
                        imageUrl: url,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        borderRadius: AppBorders.sm,
                      )
                    : Icon(
                        Icons.image_outlined,
                        size: 18,
                        color: cs.onSurface.withValues(alpha: 0.28),
                      ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            priceLabel,
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
              height: 1.1,
              fontSize: 10.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Text(
            name,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              height: 1.1,
              fontSize: 9.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
