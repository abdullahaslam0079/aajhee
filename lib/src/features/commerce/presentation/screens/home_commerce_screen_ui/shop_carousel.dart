part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _ShopCarousel extends StatelessWidget {
  const _ShopCarousel({
    required this.branches,
    required this.onBranchTap,
  });

  final List<MapBranchModel> branches;
  final ValueChanged<MapBranchModel> onBranchTap;

  static double get _cardHeight => 96.h;

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: _cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
        itemCount: branches.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final branch = branches[index];
          return Align(
            alignment: Alignment.topLeft,
            child: _NearbyShopCard(
              branch: branch,
              onTap: () => onBranchTap(branch),
            ),
          );
        },
      ),
    );
  }
}
