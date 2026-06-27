import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/home/presentation/providers/branch_offers_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class BusinessStoreScreen extends ConsumerStatefulWidget {
  const BusinessStoreScreen({
    super.key,
    required this.branch,
  });

  final MapBranchModel branch;

  @override
  ConsumerState<BusinessStoreScreen> createState() =>
      _BusinessStoreScreenState();
}

class _BusinessStoreScreenState extends ConsumerState<BusinessStoreScreen> {
  static const List<String> _coverImages = [
    'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1576618148400-f54bed99fcfd?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?auto=format&fit=crop&w=1200&q=80',
  ];

  late final ScrollController _scrollController;
  bool _showCompactHeader = false;

  MapBranchModel get branch => widget.branch;

  String get _coverFallback =>
      _coverImages[branch.id.abs() % _coverImages.length];

  String? _coverPrimaryUrl(List<OfferModel> offers) {
    if (branch.coverImageUrl != null && branch.coverImageUrl!.isNotEmpty) {
      return branch.coverImageUrl;
    }

    for (final offer in offers) {
      final imageUrl = offer.imageUrl;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return imageUrl;
      }
    }

    return null;
  }

  String? get _logoImageUrl => branch.logoUrl;

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
    final offersState = ref.watch(branchOffersProvider(branch.id));
    final offers = offersState.offers;
    final coverFallback = _coverFallback;
    final coverPrimary = _coverPrimaryUrl(offers);

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
                    _heroHeader(
                      cs,
                      muted,
                      primaryUrl: coverPrimary,
                      fallbackUrl: coverFallback,
                    ),
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
              if (offersState.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (offersState.errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _OffersError(
                    message: offersState.errorMessage!,
                    onRetry: () =>
                        ref.invalidate(branchOffersProvider(branch.id)),
                  ),
                )
              else if (offers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No offers available for this branch.',
                      style: tt.bodyLarge?.copyWith(color: muted),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
                    child: Text(
                      offers.length > 1 ? 'All Offers' : 'Featured Offer',
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
                    children: offers
                        .map(
                          (offer) => Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.ms.h),
                            child: _offerCard(
                              cs: cs,
                              tt: tt,
                              muted: muted,
                              offer: offer,
                              fallbackImageUrl: coverFallback,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
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
                    _StoreLogoBadge(
                      name: branch.displayName,
                      imageUrl: _logoImageUrl,
                    ),
                    SizedBox(width: AppSpacing.xs.w),
                    Expanded(
                      child: Text(
                        branch.displayName,
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

  Widget _heroHeader(
    ColorScheme cs,
    Color muted, {
    required String? primaryUrl,
    required String fallbackUrl,
  }) {
    return SizedBox(
      height: 225.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: cs.surfaceContainerHighest),
          NetworkImageWithFallback(
            primaryUrl: primaryUrl,
            fallbackUrl: fallbackUrl,
            debugLabel: 'hero ${branch.displayName}',
            fit: BoxFit.cover,
            errorWidget: Icon(
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
          _StoreLogoBadge(
            name: branch.displayName,
            imageUrl: _logoImageUrl,
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.displayName,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  '${branch.categoryName} • ${branch.formattedAddress}',
                  style: tt.bodyMedium?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (branch.highestDiscountPercent > 0) ...[
                  SizedBox(height: AppSpacing.xs.h),
                  Row(
                    children: [
                      Icon(Icons.local_offer_rounded,
                          size: 18, color: cs.primary),
                      SizedBox(width: AppSpacing.xxs.w),
                      Text(
                        'Up to ${branch.highestDiscountPercent.toStringAsFixed(0)}% off',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
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
        ],
      ),
    );
  }

  Widget _offerCard({
    required ColorScheme cs,
    required TextTheme tt,
    required Color muted,
    required OfferModel offer,
    required String fallbackImageUrl,
  }) {
    final imageUrl = (offer.imageUrl != null && offer.imageUrl!.isNotEmpty)
        ? offer.imageUrl
        : null;

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
                        if (offer.detailText.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.xxs.h),
                          Text(
                            offer.detailText,
                            style: tt.bodyMedium?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        SizedBox(height: AppSpacing.sm.h),
                        Row(
                          children: [
                            if (offer.discountPercent > 0)
                              _tagChip(
                                cs: cs,
                                tt: tt,
                                label:
                                    '${offer.discountPercent.toStringAsFixed(0)}% off',
                                icon: Icons.local_offer_outlined,
                              ),
                            if (offer.discountPercent > 0)
                              SizedBox(width: AppSpacing.xs.w),
                            _tagChip(
                              cs: cs,
                              tt: tt,
                              label: offer.offerType == OfferType.item
                                  ? 'Item deal'
                                  : 'Dine in',
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
                        child: NetworkImageWithFallback(
                          primaryUrl: imageUrl,
                          fallbackUrl: fallbackImageUrl,
                          debugLabel: 'offer ${offer.title}',
                          width: 108,
                          height: 96,
                          fit: BoxFit.cover,
                          borderRadius: AppBorders.md,
                          errorWidget: Container(
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

class _OffersError extends StatelessWidget {
  const _OffersError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _StoreLogoBadge extends StatelessWidget {
  const _StoreLogoBadge({
    required this.name,
    this.imageUrl,
  });

  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return StoreLogoBadge(
      name: name,
      imageUrl: imageUrl,
      size: 34,
      borderRadius: AppBorders.full,
    );
  }
}