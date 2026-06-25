import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.locationText,
    required this.onLocationTap,
    required this.onFavoritesTap,
    required this.onNotificationsTap,
  });

  final String locationText;
  final VoidCallback onLocationTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.sm.w,
        AppSpacing.xs.h,
        AppSpacing.sm.w,
        AppSpacing.sm.h,
      ),
      child: Row(
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
          SizedBox(width: AppSpacing.sm.w),
          _HeaderIconButton(
            icon: Icons.notifications_outlined,
            onPressed: onNotificationsTap,
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
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: AppBorders.lg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.lg,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorders.lg,
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.12),
            ),
            boxShadow: AppShadows.card,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.ms.w,
              vertical: AppSpacing.sm.h,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.xs.w),
                Expanded(
                  child: Text(
                    locationText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.xxs.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
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
  });

  final IconData icon;
  final VoidCallback onPressed;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;

    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: _size.w,
          height: _size.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: cs.onSurface.withValues(alpha: 0.14),
            ),
            boxShadow: AppShadows.subtle,
          ),
          child: Icon(
            icon,
            size: 21,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }
}
