part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _StoreProductCarousel extends StatelessWidget {
  const _StoreProductCarousel({
    required this.products,
    required this.onProductTap,
    required this.onAddTap,
  });

  final List<Map<String, dynamic>> products;
  final ValueChanged<Map<String, dynamic>> onProductTap;
  final ValueChanged<Map<String, dynamic>> onAddTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 168.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: products.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final raw = products[index];
          final product = CommerceProduct.fromJson(raw);
          return CommerceProductCard(
            product: product,
            width: 122.w,
            compact: true,
            primaryAdd: true,
            onTap: () => onProductTap(raw),
            onAddTap: () => onAddTap(raw),
          );
        },
      ),
    );
  }
}
