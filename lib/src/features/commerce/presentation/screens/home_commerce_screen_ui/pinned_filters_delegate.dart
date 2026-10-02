part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _PinnedFiltersDelegate extends SliverPersistentHeaderDelegate {
  _PinnedFiltersDelegate({
    required this.textTheme,
    required this.backgroundColor,
    required this.listFilter,
    required this.onFilterSelected,
  });

  final TextTheme textTheme;
  final Color backgroundColor;
  final ProductListFilter listFilter;
  final ValueChanged<ProductListFilter> onFilterSelected;

  double get _topPad => AppSpacing.xs.h.ceilToDouble();
  double get _titleGap => 2.h.ceilToDouble();
  double get _bottomPad => 2.h.ceilToDouble();
  double get _titleHeight => 20.h.ceilToDouble();
  double get _chipsHeight => 34.h.ceilToDouble();
  double get _shadowPad => 8;

  double get _contentExtent =>
      (_topPad + _titleHeight + _titleGap + _chipsHeight + _bottomPad)
          .ceilToDouble();

  double get _extent => (_contentExtent + _shadowPad).ceilToDouble();

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.08);

    return SizedBox(
      height: _extent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: backgroundColor,
            child: SizedBox(
              height: _contentExtent,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.ms.w,
                  _topPad,
                  AppSpacing.ms.w,
                  _bottomPad,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: _titleHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'All products',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: _titleGap),
                    SizedBox(
                      height: _chipsHeight,
                      child: _ProductListFilterChips(
                        selected: listFilter,
                        onSelected: onFilterSelected,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: _shadowPad,
            child: overlapsContent
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          shadowColor,
                          shadowColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  )
                : ColoredBox(color: backgroundColor),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedFiltersDelegate oldDelegate) {
    return listFilter != oldDelegate.listFilter ||
        textTheme != oldDelegate.textTheme ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
