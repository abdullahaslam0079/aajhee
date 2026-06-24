import 'dart:math' as math;

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

  static const List<String> _logoImages = [
    'https://upload.wikimedia.org/wikipedia/commons/7/79/Logo_KFC.svg',
    'https://upload.wikimedia.org/wikipedia/commons/0/03/Subway_2016_logo.svg',
    'https://upload.wikimedia.org/wikipedia/commons/a/a8/Pizza_Hut_logo_2019.svg',
    'https://upload.wikimedia.org/wikipedia/commons/4/4b/Burger_King_2020.svg',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.62);
    final isFavorite = ref.watch(
      favoriteStoresProvider.select((state) => state.isFavorite(item.id)),
    );
    final imageIndex = item.id.hashCode.abs() % _coverImages.length;
    final logoIndex = item.id.hashCode.abs() % _logoImages.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.sm,
        child: SizedBox(
          height: 225.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              
              Container(
                height: 176.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: AppBorders.md,
                  color: cs.surfaceContainerHighest,
                  // border: Border.all(
                  //   color: cs.outlineVariant,
                  //   width: 2,
                  // ),
                ),
                child: ClipRRect(
                  borderRadius: AppBorders.sm,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _coverImages[imageIndex],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.fastfood_outlined,
                          color: muted,
                          size: 34,
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.12),
                              Colors.black.withValues(alpha: 0.36),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.sm.w,
                top: AppSpacing.sm.h,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: cs.onPrimaryContainer,
                    borderRadius: AppBorders.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.discount_rounded,
                          size: 15, color: cs.onPrimary),
                      SizedBox(width: AppSpacing.xxs.w),
                      Text(
                        'Flat ${item.discountPercent}% Off',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: AppSpacing.sm.w,
                top: AppSpacing.sm.h,
                child: GestureDetector(
                  onTap: () => ref
                      .read(favoriteStoresProvider.notifier)
                      .toggle(item.id),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary.withValues(alpha: 0.88),
                    ),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: cs.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.ms.w,
                right: AppSpacing.ms.w,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.sm.r),
                  decoration: BoxDecoration(
                    color: cs.onPrimary,
                    borderRadius: AppBorders.md,
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.6),
                      width: 1,
                    ),
                    //
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52.w,
                        height: 52.w,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: AppBorders.sm,
                        ),
                        child: ClipRRect(
                          borderRadius: AppBorders.sm,
                          child: Image.network(
                            _logoImages[logoIndex],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.storefront_outlined,
                              color: muted,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            SizedBox(height: AppSpacing.xxs.h),
                            Text(
                              '${item.category} \u2022 ${_distanceText(item.position.latitude, item.position.longitude)} km',
                              style: tt.bodyMedium?.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSpacing.xs.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 14,
                                  color: cs.primary,
                                ),
                                SizedBox(width: AppSpacing.xxs.w),
                                Icon(
                                  Icons.star_rounded,
                                  size: 17,
                                  color: cs.primary,
                                ),
                                SizedBox(width: AppSpacing.xxs.w),
                                Text(
                                  _ratingText(item.discountPercent),
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                                Text(
                                  ' (${_reviewsCount(item.id)})',
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
            ],
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
