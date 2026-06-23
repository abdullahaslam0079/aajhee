import 'package:goluto/src/imports/core_imports.dart';

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
    return FloatingActionButton.small(
      heroTag: heroTag,
      backgroundColor: colorScheme.surface,
      elevation: 3,
      onPressed: onPressed,
      child: Icon(icon, color: colorScheme.onSurface),
    );
  }
}
