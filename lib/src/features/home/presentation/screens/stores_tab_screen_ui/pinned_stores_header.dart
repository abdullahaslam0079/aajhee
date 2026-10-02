part of 'package:aajhee/src/features/home/presentation/screens/stores_tab_screen.dart';

class _PinnedStoresHeader extends StatelessWidget {
  const _PinnedStoresHeader({
    required this.locationText,
    required this.unreadCount,
    required this.cartItemCount,
    required this.backgroundColor,
    required this.onLocationTap,
    required this.onFavoritesTap,
    required this.onNotificationsTap,
    required this.onCartTap,
    required this.onSearchTap,
  });

  final String locationText;
  final int unreadCount;
  final int cartItemCount;
  final Color backgroundColor;
  final VoidCallback onLocationTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onCartTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Column(
        children: [
          HomeHeader(
            locationText: locationText,
            onLocationTap: onLocationTap,
            onFavoritesTap: onFavoritesTap,
            onNotificationsTap: onNotificationsTap,
            onCartTap: onCartTap,
            notificationUnreadCount: unreadCount,
            cartItemCount: cartItemCount,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.ms.w,
              4.h,
              AppSpacing.ms.w,
              6.h,
            ),
            child: CommerceSearchBar(
              onTap: onSearchTap,
              hintText: 'Search for products, brands and more...',
            ),
          ),
        ],
      ),
    );
  }
}
