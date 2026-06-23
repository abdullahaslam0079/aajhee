import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class BusinessStoreScreen extends StatefulWidget {
  const BusinessStoreScreen({super.key});

  @override
  State<BusinessStoreScreen> createState() => _BusinessStoreScreenState();
}

class _BusinessStoreScreenState extends State<BusinessStoreScreen> {
  static const String _coverImageUrl =
      'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=1200&q=80';
  static const String _storeLogoUrl =
      'https://upload.wikimedia.org/wikipedia/sco/thumb/b/bf/KFC_logo.svg/768px-KFC_logo.svg.png';
  static const List<_StoreOffer> _offers = [
    _StoreOffer(
      title: 'Flat 30% Off',
      subtitle: 'On The Entire Bill',
      oldPriceText: 'Valid till 11:59 PM',
    ),
    _StoreOffer(
      title: 'Zinger + Drink Rs.400',
      subtitle: 'Zinger + Drink In Rs. 400',
      oldPriceText: 'Instead Of Rs. 780',
    ),
    _StoreOffer(
      title: 'Family Meal Deal',
      subtitle: '2 Burgers + 2 Drinks',
      oldPriceText: 'Save Rs. 350',
    ),
    _StoreOffer(
      title: 'Family Meal Deal',
      subtitle: '2 Burgers + 2 Drinks',
      oldPriceText: 'Save Rs. 350',
    ),
    _StoreOffer(
      title: 'Family Meal Deal',
      subtitle: '2 Burgers + 2 Drinks',
      oldPriceText: 'Save Rs. 350',
    ),
  ];

  late final ScrollController _scrollController;
  bool _showCompactHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldShowHeader = _scrollController.hasClients &&
        _scrollController.offset > (150.h);
    if (shouldShowHeader != _showCompactHeader) {
      setState(() => _showCompactHeader = shouldShowHeader);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.62);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _heroHeader(cs, muted),
                    Positioned(
                      left: AppSpacing.ms.w,
                      right: AppSpacing.ms.w,
                      bottom: -58.h,
                      child: _storeSummaryCard(cs, tt, muted),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 74.h)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
                  child: _sectionTabs(cs, tt),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: AppSpacing.ml.h)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
                  child: Text(
                    _offers.length > 1 ? 'All Offers' : 'Featured Offer',
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: AppSpacing.ms.h)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.ms.w,
                  0,
                  AppSpacing.ms.w,
                  AppSpacing.xl.h,
                ),
                sliver: SliverList.list(
                  children: _offers
                      .map((offer) => Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.ms.h),
                            child: _offerCard(
                              cs: cs,
                              tt: tt,
                              muted: muted,
                              offer: offer,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
          _animatedCompactHeader(cs, tt, muted),
        ],
      ),
    );
  }

  Widget _animatedCompactHeader(ColorScheme cs, TextTheme tt, Color muted) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.sm.w,
          AppSpacing.sm.h,
          AppSpacing.sm.w,
          0,
        ),
        child: IgnorePointer(
          ignoring: !_showCompactHeader,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            opacity: _showCompactHeader ? 1 : 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              offset: _showCompactHeader
                  ? Offset.zero
                  : const Offset(0, -0.22),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.xs.r),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.92),
                  borderRadius: AppBorders.full,
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: cs.primary.withValues(alpha: 0.12),
                        foregroundColor: cs.onSurface,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    SizedBox(width: AppSpacing.xs.w),
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        borderRadius: AppBorders.full,
                        color: cs.surfaceContainerHighest,
                      ),
                      child: ClipRRect(
                        borderRadius: AppBorders.full,
                        child: Image.network(
                          _storeLogoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.store_outlined,
                            color: muted,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs.w),
                    Expanded(
                      child: Text(
                        'Moraco Pizza',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroHeader(ColorScheme cs, Color muted) {
    return SizedBox(
      height: 225.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: cs.surfaceContainerHighest),
          Image.network(
            _coverImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.storefront_outlined,
              color: muted,
              size: 46,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.52),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.34),
                ],
                stops: const [0, 0.38, 1],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.sm.w,
                  AppSpacing.sm.h,
                  AppSpacing.sm.w,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.38),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                    IconButton.filledTonal(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.38),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.info_outline_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeSummaryCard(ColorScheme cs, TextTheme tt, Color muted) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.ms.r),
      decoration: BoxDecoration(
        color: cs.onPrimary,
        borderRadius: AppBorders.lg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              borderRadius: AppBorders.md,
              color: cs.surfaceContainerHighest,
              border:
                  Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: ClipRRect(
              borderRadius: AppBorders.md,
              child: Image.network(
                _storeLogoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.store_outlined,
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
                  'Moraco Pizza',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  'Food • 4970.44 km',
                  style: tt.bodyMedium?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 18, color: cs.primary),
                    SizedBox(width: AppSpacing.xxs.w),
                    Text(
                      '5.0',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      ' (7)',
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
    );
  }

  Widget _sectionTabs(ColorScheme cs, TextTheme tt) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.05),
        borderRadius: AppBorders.md,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: AppBorders.full,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.discount_outlined, size: 18, color: cs.primary),
                  SizedBox(width: AppSpacing.xs.w),
                  Text(
                    'Offers',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          // Expanded(
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           Icons.delivery_dining_outlined,
          //           size: 18,
          //           color: cs.onSurface.withValues(alpha: 0.35),
          //         ),
          //         SizedBox(width: AppSpacing.xs.w),
          //         Text(
          //           'Delivery',
          //           style: tt.titleSmall?.copyWith(
          //             fontWeight: FontWeight.w700,
          //             color: cs.onSurface.withValues(alpha: 0.35),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _offerCard({
    required ColorScheme cs,
    required TextTheme tt,
    required Color muted,
    required _StoreOffer offer,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppBorders.lg,
      child: InkWell(
        borderRadius: AppBorders.lg,
        onTap: () {
          context.push(AppRoutes.offerScanner);
        },
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm.r),
          decoration: BoxDecoration(
            color: cs.onPrimary,
            borderRadius: AppBorders.lg,
            // border: Border.all(color: cs.onPrimary, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm.w,
                  vertical: AppSpacing.sm.h,
                ),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: AppBorders.sm,
                ),
                child: Text(
                  offer.title,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onPrimary,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.subtitle,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface.withValues(alpha: 0.9),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs.h),
                        Text(
                          offer.oldPriceText,
                          style: tt.bodyMedium?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm.h),
                        Row(
                          children: [
                            _tagChip(
                              cs: cs,
                              tt: tt,
                              label: 'Gold',
                              icon: Icons.workspace_premium_rounded,
                            ),
                            SizedBox(width: AppSpacing.xs.w),
                            _tagChip(
                              cs: cs,
                              tt: tt,
                              label: 'Dine in',
                              icon: Icons.storefront_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: AppBorders.md,
                        child: Image.network(
                          _coverImageUrl,
                          width: 108.w,
                          height: 96.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 108.w,
                            height: 96.h,
                            color: cs.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.fastfood_outlined,
                              color: muted,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 6.w,
                        bottom: 6.h,
                        child: Container(
                          width: 26.w,
                          height: 26.w,
                          decoration: BoxDecoration(
                            color: cs.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Icon(Icons.qr_code_2_rounded,
                              size: 17, color: cs.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagChip({
    required ColorScheme cs,
    required TextTheme tt,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs.w,
        vertical: AppSpacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: AppBorders.sm,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onPrimary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: tt.labelMedium?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreOffer {
  const _StoreOffer({
    required this.title,
    required this.subtitle,
    required this.oldPriceText,
  });

  final String title;
  final String subtitle;
  final String oldPriceText;
}
