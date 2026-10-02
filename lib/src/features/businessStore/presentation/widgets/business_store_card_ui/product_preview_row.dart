part of 'package:aajhee/src/features/businessStore/presentation/widgets/business_store_card.dart';

class _ProductPreviewRow extends StatelessWidget {
  const _ProductPreviewRow({
    required this.products,
    this.onMoreTap,
  });

  final List<BranchTopProductModel> products;
  final VoidCallback? onMoreTap;

  /// ~4 thumbs visible across a typical phone card width.
  static const double _tileWidth = 64;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tileW = _tileWidth.w;
    final imageSize = tileW;
    final rowHeight = imageSize + 3.h + 13.h + 12.h;

    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                return _ProductPreviewTile(
                  product: products[index],
                  width: tileW,
                  imageSize: imageSize,
                );
              },
            ),
          ),
          SizedBox(width: 6.w),
          Padding(
            padding: EdgeInsets.only(top: (imageSize - 28.w) / 2),
            child: Material(
              color: AppBrandColors.surface,
              shape: const CircleBorder(),
              elevation: 1,
              shadowColor: Colors.black26,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onMoreTap,
                child: SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: cs.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
