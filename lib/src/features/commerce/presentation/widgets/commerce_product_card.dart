import 'package:aajhee/src/features/commerce/domain/entities/commerce_product.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/utils/money_format.dart';

/// Shared marketplace product card used by home carousels and grids.
///
/// Layout: image + discount badge, title, rating, stacked price, quick-add.
class CommerceProductCard extends StatelessWidget {
  const CommerceProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.width,
    this.onAddTap,
    this.primaryAdd = false,
    this.compact = false,
  });

  final CommerceProduct product;
  final VoidCallback onTap;
  final double? width;
  final VoidCallback? onAddTap;

  /// When true, use a primary-colored quick-add button.
  final bool primaryAdd;

  /// Tighter padding / single-line title for horizontal carousels.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final discount = product.discountLabel(short: true);
    final imageUrl = resolveMediaUrl(product.imageUrl);
    final price = formatRs(product.effectivePrice ?? product.basePrice);
    final basePrice = formatRsOrNull(product.basePrice);
    final showStrike =
        discount != null && basePrice != null && basePrice != price;
    final ratingAvg = product.ratingAvg;
    final ratingCount = product.ratingCount;
    final hasRating = ratingAvg != null &&
        ratingAvg > 0 &&
        (ratingCount == null || ratingCount > 0);
    final titleLines = compact ? 1 : 2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Ink(
          width: width,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppBorders.card,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.45),
            ),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: CommerceProductImage(imageUrl: imageUrl),
                    ),
                    if (discount != null)
                      Positioned(
                        top: 6.h,
                        left: 6.w,
                        child: _DiscountBadge(label: discount),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 7.w : 8.w,
                  compact ? 5.h : 6.h,
                  compact ? 5.w : 6.w,
                  compact ? 5.h : 6.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.displayName,
                      maxLines: titleLines,
                      overflow: TextOverflow.ellipsis,
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: cs.onSurface,
                        letterSpacing: -0.1,
                        fontSize: compact ? 11.sp : null,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    if (hasRating)
                      _CompactRating(
                        rating: ratingAvg,
                        count: ratingCount,
                      )
                    else
                      Text(
                        'New',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          fontSize: compact ? 10.sp : 10,
                        ),
                      ),
                    SizedBox(height: compact ? 4.h : 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _StackedPrice(
                            price: price,
                            basePrice: showStrike ? basePrice : null,
                            emphasize: discount != null || primaryAdd,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        _AddButton(
                          onTap: onAddTap ?? onTap,
                          primary: primaryAdd,
                          compact: compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft framed product image that always fills the available slot.
class CommerceProductImage extends StatelessWidget {
  const CommerceProductImage({
    super.key,
    required this.imageUrl,
    this.padding,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final EdgeInsetsGeometry? padding;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ColoredBox(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Image.network(
                imageUrl!,
                fit: fit,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_outlined,
                  color: cs.onSurfaceVariant,
                ),
              ),
            )
          : Icon(Icons.image_outlined, color: cs.onSurfaceVariant),
    );
  }
}

String? commerceProductLogoUrl(
  Map<String, dynamic> product, {
  Map<int, String>? logoByBusinessId,
}) {
  for (final key in const [
    'business_logo_url',
    'logo_url',
    'business_logo',
  ]) {
    final resolved = resolveMediaUrl(product[key]?.toString());
    if (resolved != null) return resolved;
  }

  if (logoByBusinessId == null || logoByBusinessId.isEmpty) return null;
  final rawId = product['business_id'];
  final businessId = rawId is int ? rawId : int.tryParse('$rawId');
  if (businessId == null) return null;
  return logoByBusinessId[businessId];
}

String? commerceDiscountLabel(
  Map<String, dynamic> product, {
  bool short = false,
}) {
  if (product['has_discount'] != true) return null;
  final raw = product['effective_discount_percent'];
  final parsed = raw is num ? raw.toDouble() : double.tryParse('$raw');
  if (parsed == null || parsed <= 0) return null;
  final value = parsed == parsed.roundToDouble()
      ? '${parsed.toInt()}%'
      : '${parsed.toStringAsFixed(0)}%';
  return short ? '-$value' : '$value off';
}

Map<int, String> commerceLogoByBusinessId(
  Map<int, String?> logos,
) {
  final map = <int, String>{};
  logos.forEach((id, url) {
    final trimmed = url?.trim();
    if (id <= 0 || trimmed == null || trimmed.isEmpty) return;
    map.putIfAbsent(id, () => trimmed);
  });
  return map;
}

class _CompactRating extends StatelessWidget {
  const _CompactRating({
    required this.rating,
    this.count,
  });

  final double rating;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final countLabel =
        count != null && count! > 0 ? ' (${_formatCount(count!)})' : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF5A623)),
        SizedBox(width: 2.w),
        Text(
          '${rating.toStringAsFixed(1)}$countLabel',
          style: tt.labelSmall?.copyWith(
            color: muted,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  static String _formatCount(int count) {
    if (count >= 1000) {
      final k = count / 1000;
      return k == k.roundToDouble()
          ? '${k.toInt()}k'
          : '${k.toStringAsFixed(1)}k';
    }
    return '$count';
  }
}

class _StackedPrice extends StatelessWidget {
  const _StackedPrice({
    required this.price,
    this.basePrice,
    this.emphasize = false,
  });

  final String price;
  final String? basePrice;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          price,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tt.labelLarge?.copyWith(
            color: emphasize ? context.appColors.deal : cs.onSurface,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -0.2,
          ),
        ),
        if (basePrice != null && basePrice!.isNotEmpty)
          Text(
            basePrice!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
              height: 1.1,
              fontSize: 10,
            ),
          ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.onTap,
    this.primary = false,
    this.compact = false,
  });

  final VoidCallback onTap;
  final bool primary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = compact ? 26.w : 28.w;
    return Material(
      color: primary ? cs.primary : cs.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.shopping_cart_outlined,
            size: compact ? 13 : 14,
            color: primary ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: appColors.deal,
        borderRadius: AppBorders.full,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: appColors.onDeal,
              fontWeight: FontWeight.w800,
              height: 1.1,
              fontSize: 10,
            ),
      ),
    );
  }
}
