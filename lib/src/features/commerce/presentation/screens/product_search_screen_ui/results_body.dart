part of 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.shops,
    required this.products,
    required this.onShopTap,
    required this.onProductTap,
  });

  final List<MapBranchModel> shops;
  final List<CommerceProduct> products;
  final ValueChanged<MapBranchModel> onShopTap;
  final ValueChanged<CommerceProduct> onProductTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final showShops = shops.isNotEmpty;
    final showProducts = products.isNotEmpty;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        if (showShops) ...[
          Text(
            'Shops',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.h),
          for (var i = 0; i < shops.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _SearchShopTile(
              branch: shops[i],
              onTap: () => onShopTap(shops[i]),
            ),
          ],
          if (showProducts) SizedBox(height: 20.h),
        ],
        if (showProducts) ...[
          Text(
            'Products',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.h),
          for (var i = 0; i < products.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _SearchProductTile(
              product: products[i],
              onTap: () => onProductTap(products[i]),
            ),
          ],
        ],
      ],
    );
  }
}
