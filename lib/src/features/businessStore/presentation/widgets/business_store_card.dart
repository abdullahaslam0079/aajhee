import 'dart:math' as math;
import 'dart:ui';

import 'package:goluto/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:goluto/src/features/shared/data/dummy_berlin_items.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class BusinessStoreCard extends ConsumerWidget {
  const BusinessStoreCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final ItemModel item;
  final VoidCallback? onTap;

  static const List<String> _coverImages = [
    'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1576618148400-f54bed99fcfd?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?auto=format&fit=crop&w=1200&q=80',
  ];

  static const Color _starColor = Color(0xFFFFB800);
  static const Color _discountColor = Color(0xFFFF9500);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.55);
    final isFavorite = ref.watch(
      favoriteStoresProvider.select((state) => state.isFavorite(item.id)),
    );
    final imageIndex = item.id.hashCode.abs() % _coverImages.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.xl,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: AppBorders.xl,
            boxShadow: AppShadows.elevated,
          ),
          child: ClipRRect(
            borderRadius: AppBorders.xl,
            child: SizedBox(
              height: 180.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _coverImages[imageIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: cs.surfaceContainerHighest,
                      child: Icon(
                        Icons.fastfood_outlined,
                        color: muted,
                        size: 34,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.02),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                        stops: const [0.45, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.ms.w,
                    top: AppSpacing.ms.h,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: _discountColor,
                        borderRadius: AppBorders.full,
                        boxShadow: AppShadows.subtle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm.w,
                          vertical: 7.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_offer_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: AppSpacing.xxs.w),
                            Text(
                              'Flat ${item.discountPercent}% Off',
                              style: tt.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: AppSpacing.ms.w,
                    top: AppSpacing.ms.h,
                    child: GestureDetector(
                      onTap: () => ref
                          .read(favoriteStoresProvider.notifier)
                          .toggle(item.id),
                      behavior: HitTestBehavior.opaque,
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.55),
                                width: 1.2,
                              ),
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite ? Colors.redAccent : Colors.white,
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.ms.w,
                    right: AppSpacing.ms.w,
                    bottom: AppSpacing.ms.h,
                    child: ClipRRect(
                      borderRadius: AppBorders.lg,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.78),
                            borderRadius: AppBorders.lg,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            boxShadow: AppShadows.card,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.sm.r),
                            child: Row(
                              children: [
                                _StoreLogoBadge(name: item.name),
                                SizedBox(width: AppSpacing.sm.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.name,
                                        style: tt.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        '${item.category} \u2022 ${_distanceText(item.position.latitude, item.position.longitude)} km',
                                        style: tt.bodyMedium?.copyWith(
                                          color: muted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: AppSpacing.xs.h),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 16,
                                            color: _starColor,
                                          ),
                                          SizedBox(width: AppSpacing.xxs.w),
                                          Text(
                                            '${_ratingText(item.discountPercent)} (${_reviewsCount(item.id)} reviews)',
                                            style: tt.bodySmall?.copyWith(
                                              color: muted,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _distanceText(double lat, double lng) {
    const baseLat = 52.5200;
    const baseLng = 13.4050;
    final km =
        math.sqrt(math.pow(lat - baseLat, 2) + math.pow(lng - baseLng, 2)) *
            111.0;
    return km.toStringAsFixed(2);
  }

  String _ratingText(int discountPercent) {
    final rating = 4.2 + (discountPercent / 100);
    return rating.clamp(0.0, 5.0).toStringAsFixed(1);
  }

  int _reviewsCount(String id) => (id.hashCode.abs() % 90) + 7;
}

class _StoreLogoBadge extends StatelessWidget {
  const _StoreLogoBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final label = _logoLabel(name);

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppBorders.sm,
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.15),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
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
