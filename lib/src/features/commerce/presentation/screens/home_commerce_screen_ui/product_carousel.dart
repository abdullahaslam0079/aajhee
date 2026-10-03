part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _ProductCarousel extends StatelessWidget {
  const _ProductCarousel({
    required this.products,
    required this.onProductTap,
    required this.onAddTap,
  });

  final List<CommerceProduct> products;
  final ValueChanged<CommerceProduct> onProductTap;
  final ValueChanged<CommerceProduct> onAddTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 168.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
        itemCount: products.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final product = products[index];
          return CommerceProductCard(
            product: product,
            width: 122.w,
            compact: true,
            primaryAdd: true,
            onTap: () => onProductTap(product),
            onAddTap: () => onAddTap(product),
          );
        },
      ),
    );
  }
}
