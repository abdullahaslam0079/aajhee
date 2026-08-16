import 'dart:ui';

import 'package:goluto/src/features/businessStore/presentation/widgets/offer_detail_sheet.dart';
import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/home/presentation/providers/branch_offers_provider.dart';
import 'package:goluto/src/features/offers/offer_feature_flags.dart';
import 'package:goluto/src/features/offerScanner/domain/offer_scanner_session.dart';
import 'package:goluto/src/features/offerScanner/domain/offer_usage_status.dart';
import 'package:goluto/src/features/offerScanner/presentation/providers/offer_usage_status_provider.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
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
  static const double _heroHeight = 238;
  static const double _cardOverlap = 88;

  late final ScrollController _scrollController;
  bool _showCompactHeader = false;

  MapBranchModel get branch => widget.branch;

  String? _coverPrimaryUrl(List<OfferModel> offers) {
    if (branch.coverImageUrl != null && branch.coverImageUrl!.isNotEmpty) {
      return branch.coverImageUrl;
    }

    for (final offer in offers) {
      final urls = offer.displayImageUrls;
      if (urls.isNotEmpty) {
        return urls.first;
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

    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 240) {
        ref.read(branchOffersProvider(branch.id).notifier).loadMore();
      }
    }
  }

  void _handleOfferTap(OfferModel offer) {
    if (offer.isViewOnlyOffer || !kOfferScannerEnabled) {
      showOfferDetailSheet(
        context,
        offer: offer,
        storeName: branch.displayName,
        storeLogoUrl: branch.logoUrl,
      );
      return;
    }

    final usageStatus = ref.read(offerUsageStatusProvider(offer));
    if (!usageStatus.isAvailable) {
      showToast(
        context,
        message: usageStatus.availabilityLabel,
        status: 'warning',
      );
      return;
    }

    context.push(
      AppRoutes.offerScanner,
      extra: OfferScannerSession(offer: offer, branchId: branch.id),
    );
  }

  Future<void> _openDirections() async {
    final result = await UrlLauncherService.instance.launchMapDirections(
      latitude: branch.latitude,
      longitude: branch.longitude,
    );

    if (!mounted) return;

    result.fold(
      (failure) => showToast(
        context,
        message: failure.message,
        status: 'error',
      ),
      (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.62);
    final offersState = ref.watch(branchOffersProvider(branch.id));
    final offers = offersState.offers;
    final coverPrimary = _coverPrimaryUrl(offers);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: (_heroHeight - _cardOverlap).h,
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: _heroHeight.h,
                            child: _heroHeader(
                              cs,
                              muted,
                              primaryUrl: coverPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.ms.w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _storeSummaryCard(cs, tt, muted),
                          SizedBox(height: AppSpacing.sm.h),
                          _sectionTabs(cs, tt),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.ml.h),
                  ],
                ),
              ),
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
                
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.ms.w,
                    0,
                    AppSpacing.ms.w,
                    AppSpacing.xl.h,
                  ),
                  sliver: SliverList.list(
                    children: [
                      ...offers.map(
                        (offer) => Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.ms.h),
                          child: _offerCard(
                            cs: cs,
                            tt: tt,
                            muted: muted,
                            offer: offer,
                          ),
                        ),
                      ),
                      if (offersState.isLoadingMore)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.md.h,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
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
  }) {
    return SizedBox(
      height: 238.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: cs.surfaceContainerHighest),
          NetworkImageWithFallback(
            primaryUrl: primaryUrl,
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
                  Colors.black.withValues(alpha: 0.45),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
                stops: const [0, 0.42, 1],
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
                    _HeroIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    _HeroIconButton(
                      icon: Icons.info_outline_rounded,
                      onPressed: () {},
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
    final savedAddress = ref.watch(savedAddressesProvider).selectedAddress;
    final userLat = savedAddress?.latitude;
    final userLng = savedAddress?.longitude;
    final distanceKm = GeoDistanceUtils.haversineKm(
      userLat ?? 52.52,
      userLng ?? 13.405,
      branch.latitude,
      branch.longitude,
    );
    final distanceLabel = GeoDistanceUtils.formatDistanceLabel(distanceKm);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.ms.w),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppBorders.lg,
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.28),
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StoreLogoBadge(
                name: branch.displayName,
                imageUrl: _logoImageUrl,
                size: 48,
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.displayName,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (branch.categoryName.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.xxs.h),
                      Text(
                        branch.categoryName,
                        style: tt.bodyMedium?.copyWith(
                          color: muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (branch.formattedAddress.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: cs.primary,
                ),
                SizedBox(width: AppSpacing.xs.w),
                Expanded(
                  child: Text(
                    branch.formattedAddress,
                    style: tt.bodyMedium?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: AppSpacing.sm.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: AppBorders.full,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.near_me_rounded,
                      size: 14,
                      color: cs.primary,
                    ),
                    SizedBox(width: AppSpacing.xxs.w),
                    Text(
                      distanceLabel,
                      style: tt.labelMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: _openDirections,
                icon: const Icon(Icons.directions_rounded, size: 18),
                label: const Text('Directions'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm.w,
                    vertical: AppSpacing.xs.h,
                  ),
                  visualDensity: VisualDensity.compact,
                  textStyle: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
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
        color: cs.surfaceContainerHigh.withValues(alpha: 0.65),
        borderRadius: AppBorders.full,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppBorders.full,
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_rounded, size: 18, color: cs.primary),
            SizedBox(width: AppSpacing.xs.w),
            Text(
              'Offers',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _offerCard({
    required ColorScheme cs,
    required TextTheme tt,
    required Color muted,
    required OfferModel offer,
  }) {
    final usageStatus = ref.watch(offerUsageStatusProvider(offer));
    final appColors = context.appColors;
    final imageUrls = offer.displayImageUrls;
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
    final isViewOnly = offer.isViewOnlyOffer;
    final statusLabel = isViewOnly
        ? offer.viewOnlyActionLabel
        : _shortStatusLabel(usageStatus);
    final statusShowsAvailable = isViewOnly || usageStatus.isAvailable;
    final isTappable = isViewOnly
        ? offer.isActive
        : usageStatus.isAvailable;
    final dealTypeLabel = offer.typeBadgeLabel;
    final description = offer.subtitle;
    final hasPrices =
        offer.originalPrice != null && offer.discountedPrice != null;
    final validityText = !hasPrices &&
            offer.isTimeLimited &&
            offer.endsAt != null
        ? offer.detailText
        : '';

    return Material(
      color: Colors.transparent,
      borderRadius: AppBorders.lg,
      child: InkWell(
        borderRadius: AppBorders.lg,
        onTap: isTappable ? () => _handleOfferTap(offer) : null,
        child: Opacity(
          opacity: isTappable ? 1 : 0.72,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: AppBorders.lg,
              border: Border.all(
                color: cs.onSurface.withValues(alpha: 0.08),
              ),
              boxShadow: AppShadows.subtle,
            ),
            child: Padding(
              padding: EdgeInsets.all(10.r),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OfferThumbnail(
                      imageUrl: imageUrl,
                      discountPercent: offer.discountPercent,
                      debugLabel: 'offer ${offer.title}',
                      showQrBadge: !isViewOnly,
                      dealColor: appColors.deal,
                      onDealColor: appColors.onDeal,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (description.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              description,
                              style: tt.labelSmall?.copyWith(
                                color: muted.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w400,
                                height: 1.35,
                                fontSize: 11,
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const Spacer(),
                          SizedBox(height: 6.h),
                          _OfferPriceRow(offer: offer),
                          if (validityText.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              validityText,
                              style: tt.labelSmall?.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: 6.h),
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 4.h,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _OfferStatusPill(
                                label: statusLabel,
                                isAvailable: statusShowsAvailable,
                              ),
                              _OfferTagChip(
                                label: dealTypeLabel,
                                icon: Icons.storefront_outlined,
                              ),
                              if (offer.isOnline)
                                const _OfferTagChip(
                                  label: 'Online',
                                  icon: Icons.language_rounded,
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
    );
  }

  String _shortStatusLabel(OfferUsageStatus status) {
    if (!status.isOfferActive) return 'Unavailable';
    if (status.isAvailable) {
      if (status.remainingUses == status.maxUses) return 'Available for you';
      return '${status.remainingUses} uses left';
    }
    return 'Limit reached';
  }
}

class _OfferThumbnail extends StatelessWidget {
  const _OfferThumbnail({
    required this.imageUrl,
    required this.discountPercent,
    required this.debugLabel,
    required this.showQrBadge,
    required this.dealColor,
    required this.onDealColor,
  });

  final String? imageUrl;
  final double discountPercent;
  final String debugLabel;
  final bool showQrBadge;
  final Color dealColor;
  final Color onDealColor;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.45);
    final size = 112.r;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: AppBorders.md,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetworkImageWithFallback(
                  primaryUrl: imageUrl,
                  debugLabel: debugLabel,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  borderRadius: AppBorders.md,
                  errorWidget: Container(
                    width: size,
                    height: size,
                    color: cs.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.local_offer_outlined,
                      color: muted,
                      size: 26,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: AppBorders.md,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cs.scrim.withValues(alpha: 0.06),
                        Colors.transparent,
                        cs.scrim.withValues(alpha: 0.12),
                      ],
                      stops: const [0, 0.45, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (discountPercent > 0)
            Positioned(
              left: 5.w,
              top: 5.h,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 3.5.h,
                ),
                decoration: BoxDecoration(
                  color: dealColor,
                  borderRadius: AppBorders.full,
                  boxShadow: AppShadows.subtle,
                ),
                child: Text(
                  '${discountPercent.toStringAsFixed(0)}% OFF',
                  style: tt.labelSmall?.copyWith(
                    color: onDealColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 9.5,
                    height: 1,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          if (showQrBadge)
            Positioned(
              right: -3.w,
              bottom: -3.h,
              child: Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cs.surfaceContainerLowest,
                    width: 2,
                  ),
                  boxShadow: AppShadows.subtle,
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 13,
                  color: cs.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OfferPriceRow extends StatelessWidget {
  const _OfferPriceRow({required this.offer});

  final OfferModel offer;

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final cs = context.theme.colorScheme;
    final appColors = context.appColors;
    final muted = cs.onSurface.withValues(alpha: 0.38);
    final original = offer.originalPrice;
    final discounted = offer.discountedPrice;

    if (original != null && discounted != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            discounted.asEuro,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: appColors.deal,
              letterSpacing: -0.4,
              height: 1,
            ),
          ),
          SizedBox(width: 6.w),
          Padding(
            padding: EdgeInsets.only(bottom: 1.h),
            child: Text(
              original.asEuro,
              style: tt.labelMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.lineThrough,
                decorationColor: muted,
                height: 1,
              ),
            ),
          ),
        ],
      );
    }

    if (offer.discountPercent > 0) {
      return Text(
        'Save ${offer.discountPercent.toStringAsFixed(0)}%',
        style: tt.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: appColors.deal,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _OfferStatusPill extends StatelessWidget {
  const _OfferStatusPill({
    required this.label,
    required this.isAvailable,
  });

  final String label;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final backgroundColor = isAvailable
        ? cs.primary.withValues(alpha: 0.08)
        : cs.errorContainer.withValues(alpha: 0.35);
    final foregroundColor =
        isAvailable ? cs.primary : cs.onErrorContainer;
    final icon = isAvailable
        ? Icons.check_circle_outline_rounded
        : Icons.block_rounded;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7.w,
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppBorders.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foregroundColor),
          SizedBox(width: 3.w),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferTagChip extends StatelessWidget {
  const _OfferTagChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7.w,
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: AppBorders.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: cs.onSurfaceVariant),
          SizedBox(width: 3.w),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
              height: 1.1,
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
    this.size = 34,
  });

  final String name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return StoreLogoBadge(
      name: name,
      imageUrl: imageUrl,
      size: size,
      borderRadius: AppBorders.md,
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppBorders.iconButton,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.white.withValues(alpha: 0.22),
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppBorders.iconButton,
            child: SizedBox(
              width: 44.w,
              height: 44.w,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}