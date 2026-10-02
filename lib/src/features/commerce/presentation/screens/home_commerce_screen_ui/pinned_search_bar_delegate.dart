part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _PinnedSearchBarDelegate extends SliverPersistentHeaderDelegate {
  _PinnedSearchBarDelegate({
    required this.backgroundColor,
    required this.onTap,
  });

  final Color backgroundColor;
  final VoidCallback onTap;

  double get _topPad => 2.h.ceilToDouble();
  double get _bottomPad => 2.h.ceilToDouble();
  double get _barHeight => (12.h * 2 + 18).ceilToDouble();
  double get _extent => (_topPad + _barHeight + _bottomPad).ceilToDouble();

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: SizedBox(
        height: _extent,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.ms.w,
            _topPad,
            AppSpacing.ms.w,
            _bottomPad,
          ),
          child: CommerceSearchBar(
            onTap: onTap,
            hintText: 'Search shops & products',
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchBarDelegate oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor;
  }
}
