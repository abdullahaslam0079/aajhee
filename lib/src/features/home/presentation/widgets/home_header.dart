import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.locationText,
    required this.onLocationTap,
    required this.onFavoritesTap,
    required this.onNotificationsTap,
    this.onCartTap,
    this.notificationUnreadCount = 0,
    this.cartItemCount = 0,
  });

  final String locationText;
  final VoidCallback onLocationTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback? onCartTap;
  final int notificationUnreadCount;
  final int cartItemCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.ms.w,
        vertical: AppSpacing.xs.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _LocationBar(
              locationText: locationText,
              onTap: onLocationTap,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          _HeaderIconButton(
            icon: Icons.favorite_border_rounded,
            onPressed: onFavoritesTap,
          ),
          SizedBox(width: 8.w),
          _HeaderIconButton(
            icon: Icons.notifications_none_rounded,
            onPressed: onNotificationsTap,
            showDot: notificationUnreadCount > 0,
          ),
          if (onCartTap != null) ...[
            SizedBox(width: 8.w),
            _HeaderIconButton(
              icon: Icons.shopping_cart_outlined,
              onPressed: onCartTap!,
              badgeCount: cartItemCount,
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationBar extends StatelessWidget {
  const _LocationBar({
    required this.locationText,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final String locationText;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.md,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: colorScheme.primary,
                    size: 14,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Deliver to',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.48),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      locationText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.badgeCount = 0,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final int badgeCount;
  final bool showDot;

  static const double _size = 38;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final showBadge = badgeCount > 0;
    final label = badgeCount > 99 ? '99+' : '$badgeCount';
    final outline = cs.outline.withValues(alpha: 0.55);
    const fill = AppBrandColors.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppBorders.iconButton,
        child: Ink(
          width: _size.w,
          height: _size.w,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppBorders.iconButton,
            border: Border.all(color: outline),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: cs.onSurface.withValues(alpha: 0.88),
              ),
              if (showDot && !showBadge)
                Positioned(
                  top: 7,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: cs.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: fill, width: 1.5),
                    ),
                  ),
                ),
              if (showBadge)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: cs.error,
                      borderRadius: AppBorders.full,
                      border: Border.all(color: fill, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: cs.onError,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
