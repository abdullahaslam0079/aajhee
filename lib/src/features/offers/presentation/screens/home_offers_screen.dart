import 'package:goluto/src/features/businessStore/presentation/widgets/offer_detail_sheet.dart';
import 'package:goluto/src/features/bottomNavigator/presentation/controllers/bottom_nav_bar_controller.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:goluto/src/features/home/presentation/widgets/home_header.dart';
import 'package:goluto/src/features/location/presentation/providers/location_provider.dart';
import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:goluto/src/features/offers/presentation/providers/all_offers_provider.dart';
import 'package:goluto/src/features/offers/presentation/providers/top_picks_provider.dart';
import 'package:goluto/src/features/offers/presentation/widgets/offer_list_card.dart';
import 'package:goluto/src/features/offers/presentation/widgets/offers_home_chrome.dart';
import 'package:goluto/src/features/offers/presentation/widgets/top_pick_offer_card.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

/// Home tab: top picks + all offers with channel filters.
///
/// Sticky while scrolling: address header → search → filters.
/// Top picks carousel scrolls away between search and filters.
class HomeOffersScreen extends ConsumerStatefulWidget {
  const HomeOffersScreen({super.key});

  @override
  ConsumerState<HomeOffersScreen> createState() => _HomeOffersScreenState();
}

class _HomeOffersScreenState extends ConsumerState<HomeOffersScreen> {
  final _scrollController = ScrollController();
  int? _lastSeenTabIndex;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(_ensureLoaded);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(allOffersFeedProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(topPicksFeedProvider.notifier).load(),
      ref.read(allOffersFeedProvider.notifier).load(),
      ref.read(notificationsProvider.notifier).refreshUnreadCount(),
    ]);
  }

  Future<void> _ensureLoaded() async {
    final topPicks = ref.read(topPicksFeedProvider);
    final allOffers = ref.read(allOffersFeedProvider);
    await Future.wait([
      if (topPicks.offers.isEmpty && !topPicks.isLoading)
        ref.read(topPicksFeedProvider.notifier).load(),
      if (allOffers.offers.isEmpty && !allOffers.isLoading)
        ref.read(allOffersFeedProvider.notifier).load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavBarControllerProvider);
    final topPicksState = ref.watch(topPicksFeedProvider);
    final allOffersState = ref.watch(allOffersFeedProvider);
    final locationState = ref.watch(locationProvider);
    final savedAddressesState = ref.watch(savedAddressesProvider);
    final unreadCount = ref.watch(
      notificationsProvider.select((state) => state.unreadCount),
    );
    final tt = context.theme.textTheme;
    final canvas = homeCanvasOf(context);
    final bottomInset =
        kHomeFeedBottomInset + MediaQuery.paddingOf(context).bottom;
    final visibleOffers = allOffersState.visibleOffers;
    final locationText = savedAddressesState.selectedAddress?.shortLabel ??
        locationState.address ??
        'Add delivery address';

    if (_lastSeenTabIndex != selectedIndex) {
      _lastSeenTabIndex = selectedIndex;
      if (selectedIndex == 0) {
        Future.microtask(_ensureLoaded);
      }
    }

    return Scaffold(
      backgroundColor: canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedHomeHeaderDelegate(
                  locationText: locationText,
                  unreadCount: unreadCount,
                  backgroundColor: canvas,
                  onLocationTap: () =>
                      showDeliveryAddressPicker(context, ref),
                  onFavoritesTap: () => context.push(AppRoutes.favorites),
                  onNotificationsTap: () =>
                      context.push(AppRoutes.notifications),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedSearchBarDelegate(
                  backgroundColor: canvas,
                  onTap: () => context.push(AppRoutes.searchOffers),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.ms.w,
                    AppSpacing.sm.h,
                    AppSpacing.ms.w,
                    AppSpacing.xs.h,
                  ),
                  child: TopPicksSectionHeader(
                    onViewAll: () => context.push(AppRoutes.topPicks),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _TopPicksCarousel(
                  state: topPicksState,
                  onRetry: () =>
                      ref.read(topPicksFeedProvider.notifier).load(),
                  onOfferTap: (offer) => _openOffer(context, offer),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedFiltersDelegate(
                  textTheme: tt,
                  backgroundColor: canvas,
                  channelFilter: allOffersState.channelFilter,
                  onChannelSelected: (filter) => ref
                      .read(allOffersFeedProvider.notifier)
                      .setChannelFilter(filter),
                ),
              ),
              if (allOffersState.isLoading && allOffersState.offers.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (allOffersState.errorMessage != null &&
                  allOffersState.offers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                    child: _ErrorState(
                      message: allOffersState.errorMessage!,
                      onRetry: () =>
                          ref.read(allOffersFeedProvider.notifier).load(),
                    ),
                  ),
                )
              else if (visibleOffers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                    child: _EmptyState(
                      channelFilter: allOffersState.channelFilter,
                      onBrowseStores: () => ref
                          .read(bottomNavBarControllerProvider.notifier)
                          .setSelectedIndex(2),
                      onClearFilter: allOffersState.channelFilter ==
                              OfferChannelFilter.all
                          ? null
                          : () => ref
                              .read(allOffersFeedProvider.notifier)
                              .setChannelFilter(OfferChannelFilter.all),
                    ),
                  ),
                )
              else
                // Top pad is 0 — sticky filters reserve shadow space below chips.
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.ms.w,
                    0,
                    AppSpacing.ms.w,
                    bottomInset,
                  ),
                  sliver: SliverList.separated(
                    itemCount: visibleOffers.length +
                        (allOffersState.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSpacing.sm.h),
                    itemBuilder: (context, index) {
                      if (index >= visibleOffers.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final offer = visibleOffers[index];
                      return OfferListCard(
                        offer: offer,
                        onTap: () => _openOffer(context, offer),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openOffer(BuildContext context, OfferModel offer) async {
    await showOfferDetailSheet(
      context,
      offer: offer,
      storeName: offer.businessName,
    );
  }
}

class _PinnedHomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHomeHeaderDelegate({
    required this.locationText,
    required this.unreadCount,
    required this.backgroundColor,
    required this.onLocationTap,
    required this.onFavoritesTap,
    required this.onNotificationsTap,
  });

  final String locationText;
  final int unreadCount;
  final Color backgroundColor;
  final VoidCallback onLocationTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onNotificationsTap;

  /// Padding + content; 44.h leaves room for location column + 40 icon buttons.
  double get _extent =>
      (AppSpacing.xs.h * 2 + 44.h).ceilToDouble();

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: SizedBox(
        height: _extent,
        child: HomeHeader(
          locationText: locationText,
          onLocationTap: onLocationTap,
          onFavoritesTap: onFavoritesTap,
          onNotificationsTap: onNotificationsTap,
          notificationUnreadCount: unreadCount,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHomeHeaderDelegate oldDelegate) {
    return locationText != oldDelegate.locationText ||
        unreadCount != oldDelegate.unreadCount ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class _PinnedSearchBarDelegate extends SliverPersistentHeaderDelegate {
  _PinnedSearchBarDelegate({
    required this.backgroundColor,
    required this.onTap,
  });

  final Color backgroundColor;
  final VoidCallback onTap;

  double get _topPad => 4.h.ceilToDouble();
  double get _bottomPad => 4.h.ceilToDouble();
  double get _barHeight => (13.h * 2 + 20).ceilToDouble();
  double get _extent => (_topPad + _barHeight + _bottomPad).ceilToDouble();

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: SizedBox(
        height: _extent,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.ms.w,
            _topPad,
            AppSpacing.ms.w,
            _bottomPad,
          ),
          child: OffersSearchBar(onTap: onTap),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchBarDelegate oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor;
  }
}

class _PinnedFiltersDelegate extends SliverPersistentHeaderDelegate {
  _PinnedFiltersDelegate({
    required this.textTheme,
    required this.backgroundColor,
    required this.channelFilter,
    required this.onChannelSelected,
  });

  final TextTheme textTheme;
  final Color backgroundColor;
  final OfferChannelFilter channelFilter;
  final ValueChanged<OfferChannelFilter> onChannelSelected;

  double get _topPad => AppSpacing.sm.h.ceilToDouble();
  double get _titleGap => AppSpacing.xs.h.ceilToDouble();
  double get _bottomPad => AppSpacing.xs.h.ceilToDouble();
  double get _titleHeight => 20.h.ceilToDouble();
  double get _chipsHeight => 34.h.ceilToDouble();
  /// Extra space so the sticky shadow isn't clipped by the header extent.
  double get _shadowPad => 8.0;

  double get _contentExtent =>
      (_topPad + _titleHeight + _titleGap + _chipsHeight + _bottomPad)
          .ceilToDouble();

  double get _extent => (_contentExtent + _shadowPad).ceilToDouble();

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Black shadow vanishes on dark canvas — use a soft light edge instead.
    final shadowColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.08);

    return SizedBox(
      height: _extent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: backgroundColor,
            child: SizedBox(
              height: _contentExtent,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.ms.w,
                  _topPad,
                  AppSpacing.ms.w,
                  _bottomPad,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: _titleHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'All offers',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: _titleGap),
                    SizedBox(
                      height: _chipsHeight,
                      child: OfferChannelFilterChips(
                        selected: channelFilter,
                        onSelected: onChannelSelected,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: _shadowPad,
            child: overlapsContent
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          shadowColor,
                          shadowColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  )
                : ColoredBox(color: backgroundColor),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedFiltersDelegate oldDelegate) {
    return channelFilter != oldDelegate.channelFilter ||
        textTheme != oldDelegate.textTheme ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class _TopPicksCarousel extends StatelessWidget {
  const _TopPicksCarousel({
    required this.state,
    required this.onRetry,
    required this.onOfferTap,
  });

  final TopPicksState state;
  final VoidCallback onRetry;
  final ValueChanged<OfferModel> onOfferTap;

  static const _carouselHeight = 208.0;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.offers.isEmpty) {
      return SizedBox(
        height: _carouselHeight.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null && state.offers.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
        child: _InlineError(message: state.errorMessage!, onRetry: onRetry),
      );
    }

    if (state.offers.isEmpty) {
      return const SizedBox.shrink();
    }

    final topOffers = state.offers.take(8).toList();

    return SizedBox(
      height: _carouselHeight.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
        itemCount: topOffers.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final offer = topOffers[index];
          return TopPickOfferCard(
            offer: offer,
            onTap: () => onOfferTap(offer),
          );
        },
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.35),
        borderRadius: AppBorders.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: tt.bodySmall?.copyWith(color: cs.onErrorContainer),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.channelFilter,
    required this.onBrowseStores,
    this.onClearFilter,
  });

  final OfferChannelFilter channelFilter;
  final VoidCallback onBrowseStores;
  final VoidCallback? onClearFilter;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isFiltered = channelFilter != OfferChannelFilter.all;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.local_offer_outlined,
          size: 56,
          color: cs.primary.withValues(alpha: 0.75),
        ),
        SizedBox(height: AppSpacing.md.h),
        Text(
          isFiltered
              ? 'No ${channelFilter.label.toLowerCase()} offers'
              : 'No offers yet',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          isFiltered
              ? 'Try another filter or browse all deals.'
              : 'Check back soon for deals nearby and online.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        SizedBox(height: AppSpacing.lg.h),
        if (onClearFilter != null)
          FilledButton(
            onPressed: onClearFilter,
            child: const Text('Show all offers'),
          )
        else
          FilledButton(
            onPressed: onBrowseStores,
            child: const Text('Browse stores'),
          ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline_rounded, size: 56, color: cs.error),
        SizedBox(height: AppSpacing.md.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        SizedBox(height: AppSpacing.lg.h),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
