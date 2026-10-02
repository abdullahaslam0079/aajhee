part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

class _QtyIconButton extends StatelessWidget {
  const _QtyIconButton({
    required this.icon,
    required this.onPressed,
    required this.tone,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: tone),
      visualDensity: VisualDensity.compact,
    );
  }
}
