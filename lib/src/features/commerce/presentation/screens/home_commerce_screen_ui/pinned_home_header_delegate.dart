part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _PinnedHomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHomeHeaderDelegate({
    required this.locationText,
    required this.unreadCount,
    required this.cartCount,
    required this.backgroundColor,
    required this.onLocationTap,
    required this.onFavoritesTap,
    required this.onNotificationsTap,
    required this.onCartTap,
  });

  final String locationText;
  final int unreadCount;
  final int cartCount;
  final Color backgroundColor;
  final VoidCallback onLocationTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onCartTap;

  double get _extent => (AppSpacing.xs.h * 2 + 44.h).ceilToDouble();

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
        child: HomeHeader(
          locationText: locationText,
          onLocationTap: onLocationTap,
          onFavoritesTap: onFavoritesTap,
          onNotificationsTap: onNotificationsTap,
          onCartTap: onCartTap,
          notificationUnreadCount: unreadCount,
          cartItemCount: cartCount,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHomeHeaderDelegate oldDelegate) {
    return locationText != oldDelegate.locationText ||
        unreadCount != oldDelegate.unreadCount ||
        cartCount != oldDelegate.cartCount ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
