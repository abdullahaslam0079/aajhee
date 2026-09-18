import 'package:aajhee/src/imports/core_imports.dart';

class MapActionButton extends StatelessWidget {
  const MapActionButton({
    super.key,
    required this.heroTag,
    required this.icon,
    required this.onPressed,
  });

  final String heroTag;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    return FloatingActionButton.small(
      heroTag: heroTag,
      backgroundColor: isDark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surfaceContainerLowest,
      foregroundColor: colorScheme.onSurface,
      elevation: isDark ? 4 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.iconButton,
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.18),
        ),
      ),
      onPressed: onPressed,
      child: Icon(icon, color: colorScheme.onSurface),
    );
  }
}
