import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:goluto/src/features/shared/data/dummy_berlin_items.dart';
import 'package:goluto/src/routing/app_routes.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({
    super.key,
    this.imageUrl =
        'https://plus.unsplash.com/premium_photo-1664392147011-2a720f214e01?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZHVjdHxlbnwwfHwwfHx8MA%3D%3D',
    this.storeLogoUrl =
        'https://www.clipartmax.com/png/middle/27-271548_dominos-pizza-dominos-pizza-logo-png.png',
    required this.item,
  });

  final ItemModel item;
  final String imageUrl;
  final String storeLogoUrl;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _favorite = false;

  static const double _heroHeight = 320;
  static const double _radius = 20;

  void _handleBackPressed() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    context.go(AppRoutes.bottomNavigator);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.55);
    final padH = AppSpacing.pagePadding.w;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: _heroHeight,
                backgroundColor: cs.surface,
                leading: Padding(
                  padding: EdgeInsets.only(left: AppSpacing.xs.w),
                  child: IconButton.filledTonal(
                    onPressed: _handleBackPressed,
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.35),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: AppSpacing.sm.w),
                    child: IconButton.filledTonal(
                      onPressed: () => setState(() => _favorite = !_favorite),
                      icon: Icon(
                        _favorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.35),
                        foregroundColor: _favorite
                            ? cs.error
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: cs.surfaceContainerHighest),
                      Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: muted,
                            size: 48,
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                            stops: const [0, 0.35, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        left: AppSpacing.md.w,
                        bottom: AppSpacing.lg.h,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: cs.error,
                            borderRadius: AppBorders.full,
                            boxShadow: [
                              BoxShadow(
                                color: cs.error.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.ms.w,
                              vertical: AppSpacing.xs.h,
                            ),
                            child: Text(
                              '${widget.item.discountPercent}% off',
                              style: tt.labelMedium?.copyWith(
                                color: cs.onError,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -_radius),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: AppBorders.bottomSheet,
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        padH,
                        AppSpacing.ml.h,
                        padH,
                        120.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: tt.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 20,
                                color: cs.primary,
                              ),
                              SizedBox(width: AppSpacing.xs.w),
                              Expanded(
                                child: Text(
                                  widget.item.address,
                                  style: tt.titleMedium?.copyWith(
                                    color: muted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: AppSpacing.xs.h,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer.withValues(
                                    alpha: 0.65,
                                  ),
                                  borderRadius: AppBorders.md,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 18,
                                      color: cs.primary,
                                    ),
                                    SizedBox(width: AppSpacing.xs.w),
                                    Text(
                                      widget.item.eta,
                                      style: tt.labelMedium?.copyWith(
                                        color: cs.onPrimaryContainer,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 22.h),
                          Material(
                            color: cs.surfaceContainerHighest.withValues(
                              alpha: 0.65,
                            ),
                            borderRadius: AppBorders.lg,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: AppBorders.lg,
                              child: Padding(
                                padding: EdgeInsets.all(14.r),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22.r,
                                      backgroundColor: cs.surfaceContainerHigh,
                                      child: ClipOval(
                                        child: Image.network(
                                          widget.storeLogoUrl,
                                          width: 36.w,
                                          height: 36.w,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.storefront_outlined,
                                            size: 22,
                                            color: muted,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.ms.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.item.category,
                                            style: tt.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            widget.item.subtitle,
                                            style: tt.bodySmall?.copyWith(
                                              color: muted,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: muted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg.h),
                          Text(
                            'About this offer',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm.h),
                          Text(
                            widget.item.offerText,
                            style: tt.bodyLarge?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.82),
                              height: 1.55,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg.h),
                          Wrap(
                            spacing: AppSpacing.sm.w,
                            runSpacing: AppSpacing.sm.h,
                            children: [
                              _ChipLabel(
                                icon: Icons.local_fire_department_outlined,
                                label: 'Popular pick',
                                colorScheme: cs,
                                textTheme: tt,
                              ),
                              _ChipLabel(
                                icon: Icons.restaurant_outlined,
                                label: widget.item.category,
                                colorScheme: cs,
                                textTheme: tt,
                              ),
                              _ChipLabel(
                                icon: Icons.delivery_dining_outlined,
                                label: 'Takeaway OK',
                                colorScheme: cs,
                                textTheme: tt,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    padH,
                    AppSpacing.ms.h,
                    padH,
                    AppSpacing.ms.h,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Offer',
                              style: tt.labelMedium?.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xxs.h),
                            Text(
                              '${widget.item.discountPercent}% off',
                              style: tt.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: cs.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 28.w,
                            vertical: AppSpacing.md.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppBorders.md,
                          ),
                        ),
                        child: Text(
                          'Get this deal',
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.ms.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        borderRadius: AppBorders.full,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          SizedBox(width: AppSpacing.xs.w),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}
