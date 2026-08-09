import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class StoreLogoBadge extends StatelessWidget {
  const StoreLogoBadge({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
    this.borderRadius,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final radius = borderRadius ?? AppBorders.md;
    final side = size.w;
    final fallback = _businessIconBadge(context, cs, side);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return SizedBox(
        width: side,
        height: side,
        child: ClipRRect(
          borderRadius: radius,
          child: CommonImage(
            imageUrl: imageUrl!,
            width: side,
            height: side,
            fit: BoxFit.cover,
            borderRadius: radius,
            onError: (url, error) {
              AppLogger.warning(
                '[Logo] Failed for "$name": url=$url error=$error — showing business icon',
              );
            },
            errorWidget: fallback,
          ),
        ),
      );
    }

    AppLogger.info('[Logo] No logo URL for "$name" — showing business icon');
    return fallback;
  }

  Widget _businessIconBadge(BuildContext context, ColorScheme cs, double side) {
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: borderRadius ?? AppBorders.md,
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.15),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_outlined,
        size: (side * 0.48).clamp(12.0, 28.0),
        color: cs.onSurfaceVariant,
      ),
    );
  }
}
