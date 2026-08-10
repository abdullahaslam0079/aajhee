import 'package:goluto/src/features/offers/data/services/engagement_service.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'top_picks_provider.g.dart';

class TopPicksState {
  const TopPicksState({
    this.offers = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<OfferModel> offers;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  TopPicksState copyWith({
    List<OfferModel>? offers,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TopPicksState(
      offers: offers ?? this.offers,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@Riverpod(keepAlive: true)
EngagementService engagementService(Ref ref) {
  return EngagementService.instance;
}

@Riverpod(keepAlive: true)
class TopPicksFeed extends _$TopPicksFeed {
  static const _pageSize = 20;

  EngagementService get _engagementService =>
      ref.read(engagementServiceProvider);
  int _requestId = 0;

  @override
  TopPicksState build() {
    return const TopPicksState();
  }

  Future<void> load() => _fetch(reset: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    await _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset}) async {
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
      final result = await _engagementService.getTopPicksFeed(
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
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load top picks feed', error, stackTrace);
      if (!ref.mounted || requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Could not load top picks. Please try again.',
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
