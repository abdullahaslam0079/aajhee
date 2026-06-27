import 'dart:math' as math;

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
    final radius = borderRadius ?? AppBorders.sm;
    final initials = _initialsBadge(context, cs);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: CommonImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          borderRadius: radius,
          onError: (url, error) {
            AppLogger.warning(
              '[Logo] Failed for "$name": url=$url error=$error — showing initials',
            );
          },
          errorWidget: initials,
        ),
      );
    }

    AppLogger.info('[Logo] No logo URL for "$name" — showing initials');
    return initials;
  }

  Widget _initialsBadge(BuildContext context, ColorScheme cs) {
    final tt = context.theme.textTheme;

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: borderRadius ?? AppBorders.sm,
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.15),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _logoLabel(name),
        textAlign: TextAlign.center,
        style: tt.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          height: 1.05,
          color: cs.onSurface,
        ),
      ),
    );
  }

  String _logoLabel(String storeName) {
    final words = storeName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'GO';
    final firstWord = words.first;
    return firstWord
        .substring(0, math.min(firstWord.length, 9))
        .toUpperCase();
  }
}
