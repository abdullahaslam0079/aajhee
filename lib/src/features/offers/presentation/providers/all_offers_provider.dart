import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/home/data/services/discovery_service.dart';
import 'package:goluto/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_offers_provider.g.dart';

class AllOffersState {
  const AllOffersState({
    this.offers = const [],
    this.channelFilter = OfferChannelFilter.all,
    this.page = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<OfferModel> offers;
  final OfferChannelFilter channelFilter;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  List<OfferModel> get visibleOffers => channelFilter == OfferChannelFilter.all
      ? offers
      : offers.where(channelFilter.matches).toList();

  AllOffersState copyWith({
    List<OfferModel>? offers,
    OfferChannelFilter? channelFilter,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AllOffersState(
      offers: offers ?? this.offers,
      channelFilter: channelFilter ?? this.channelFilter,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@Riverpod(keepAlive: true)
class AllOffersFeed extends _$AllOffersFeed {
  static const _pageSize = 20;
  static const _minVisibleWhenFiltered = 8;

  DiscoveryService get _discoveryService => ref.read(discoveryServiceProvider);
  int _requestId = 0;

  @override
  AllOffersState build() => const AllOffersState();

  Future<void> load() => _fetch(reset: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    await _fetch(reset: false);
  }

  Future<void> setChannelFilter(OfferChannelFilter filter) async {
    if (state.channelFilter == filter) return;
    state = state.copyWith(channelFilter: filter);
    if (filter != OfferChannelFilter.all &&
        state.visibleOffers.length < _minVisibleWhenFiltered &&
        state.hasMore) {
      await _ensureFilteredVisible();
    }
  }

  Future<void> _ensureFilteredVisible() async {
    var guard = 0;
    while (ref.mounted &&
        state.hasMore &&
        !state.isLoading &&
        !state.isLoadingMore &&
        state.visibleOffers.length < _minVisibleWhenFiltered &&
        guard < 5) {
      guard++;
      await _fetch(reset: false, autoFill: false);
    }
  }

  Future<void> _fetch({required bool reset, bool autoFill = true}) async {
    final requestId = ++_requestId;
    final nextPage = reset ? 1 : state.page + 1;

    state = state.copyWith(
      isLoading: reset,
      isLoadingMore: !reset,
      offers: reset ? const [] : state.offers,
      clearError: true,
    );

    try {
      await ref.read(savedAddressesProvider.notifier).ensureLoaded();
      if (!ref.mounted || requestId != _requestId) return;

      final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
      final result = await _discoveryService.getOffers(
        addressId: addressId,
        page: nextPage,
        pageSize: _pageSize,
      );
      if (!ref.mounted || requestId != _requestId) return;

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          );
        },
        (page) {
          final offers = reset
              ? page.results
              : [...state.offers, ...page.results];
          state = state.copyWith(
            offers: offers,
            page: page.page,
            hasMore: page.hasMore,
            isLoading: false,
            isLoadingMore: false,
            clearError: true,
          );
        },
      );

      if (autoFill &&
          ref.mounted &&
          requestId == _requestId &&
          state.channelFilter != OfferChannelFilter.all &&
          state.visibleOffers.length < _minVisibleWhenFiltered &&
          state.hasMore) {
        await _ensureFilteredVisible();
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load all offers feed', error, stackTrace);
      if (!ref.mounted || requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Could not load offers. Please try again.',
      );
    }
  }

  void updateOffer(OfferModel updated) {
    state = state.copyWith(
      offers: [
        for (final offer in state.offers)
          if (offer.id == updated.id) updated else offer,
      ],
    );
  }
}
