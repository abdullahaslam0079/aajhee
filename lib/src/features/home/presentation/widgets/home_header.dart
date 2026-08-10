import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.locationText,
    required this.onLocationTap,
    required this.onFavoritesTap,
    required this.onNotificationsTap,
    this.notificationUnreadCount = 0,
  });

  final String locationText;
  final VoidCallback onLocationTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onNotificationsTap;
  final int notificationUnreadCount;

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
          SizedBox(width: 6.w),
          _HeaderIconButton(
            icon: Icons.notifications_none_rounded,
            onPressed: onNotificationsTap,
            badgeCount: notificationUnreadCount,
          ),
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
              Text(
                'Location',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.48),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: colorScheme.primary,
                    size: 15,
                  ),
                  SizedBox(width: 4.w),
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
  });

  final IconData icon;
  final VoidCallback onPressed;
  final int badgeCount;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final showBadge = badgeCount > 0;
    final label = badgeCount > 99 ? '99+' : '$badgeCount';

    return Material(
      color: cs.brightness == Brightness.dark
          ? cs.surfaceContainerHigh
          : cs.onSurface.withValues(alpha: 0.05),
      shape: AppBorders.shapeIconButton,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppBorders.iconButton,
        child: SizedBox(
          width: _size.w,
          height: _size.w,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: cs.onSurface.withValues(alpha: 0.78),
              ),
              if (showBadge)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: cs.error,
                      borderRadius: AppBorders.full,
                      border: Border.all(color: cs.surface, width: 1.5),
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
