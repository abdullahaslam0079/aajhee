import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class StoreLogoBadge extends StatelessWidget {
  const StoreLogoBadge({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
    this.width,
    this.borderRadius,
  });

  final String name;
  final String? imageUrl;

  /// Height (and width when [width] is null).
  final double size;

  /// Optional width. When null, the badge stays square using [size].
  final double? width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final radius = borderRadius ?? AppBorders.md;
    final h = size.w;
    final w = (width ?? size).w;
    final fallback = _businessIconBadge(context, cs, w, h);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return SizedBox(
        width: w,
        height: h,
        child: ClipRRect(
          borderRadius: radius,
          child: CommonImage(
            imageUrl: imageUrl!,
            width: w,
            height: h,
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

  Widget _businessIconBadge(
    BuildContext context,
    ColorScheme cs,
    double w,
    double h,
  ) {
    return Container(
      width: w,
      height: h,
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
        size: (h * 0.48).clamp(12.0, 28.0),
        color: cs.onSurfaceVariant,
      ),
    );
  }
}
