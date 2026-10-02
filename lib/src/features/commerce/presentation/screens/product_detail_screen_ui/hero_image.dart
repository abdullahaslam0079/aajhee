part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.imageUrl,
    this.discountLabel,
  });

  final String? imageUrl;
  final String? discountLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    // Compact marketplace frame: always filled, no letterboxing.
    final height = (width * 0.72).clamp(200.0, 260.0);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: cs.surfaceContainerHighest,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: height,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
          ),
          if (discountLabel != null)
            Positioned(
              top: 10.h,
              left: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: context.appColors.deal,
                  borderRadius: AppBorders.full,
                ),
                child: Text(
                  discountLabel!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.appColors.onDeal,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
