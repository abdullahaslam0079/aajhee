part of 'package:aajhee/src/features/commerce/presentation/screens/order_detail_screen.dart';

class _ItemImageFallback extends StatelessWidget {
  const _ItemImageFallback({
    required this.initial,
    required this.colorScheme,
    required this.textTheme,
  });

  final String initial;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colorScheme.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          initial,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
