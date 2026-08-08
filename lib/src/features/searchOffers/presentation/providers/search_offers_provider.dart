import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/home/data/services/discovery_service.dart';
import 'package:goluto/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_offers_provider.g.dart';

class SearchOffersState {
  const SearchOffersState({
    this.query = '',
    this.offers = const [],
    this.page = 0,
    this.totalCount = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final String query;
  final List<OfferModel> offers;
  final int page;
  final int totalCount;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasQuery => query.trim().isNotEmpty;

  SearchOffersState copyWith({
    String? query,
    List<OfferModel>? offers,
    int? page,
    int? totalCount,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchOffersState(
      query: query ?? this.query,
      offers: offers ?? this.offers,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@Riverpod(keepAlive: false)
class SearchOffers extends _$SearchOffers {
  static const _pageSize = 20;

  late final DiscoveryService _discoveryService;
  int _requestId = 0;

  @override
  SearchOffersState build() {
    _discoveryService = ref.read(discoveryServiceProvider);
    return const SearchOffersState();
  }

  void clear() {
    _requestId++;
    state = const SearchOffersState();
  }

  Future<void> search(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      clear();
      return;
    }
    await _search(query: trimmed, reset: true);
  }

  Future<void> refresh() async {
    final query = state.query.trim();
    if (query.isEmpty) return;
    await _search(query: query, reset: true);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    final query = state.query.trim();
    if (query.isEmpty) return;
    await _search(query: query, reset: false);
  }

  Future<void> _search({
    required String query,
    required bool reset,
  }) async {
    final requestId = ++_requestId;
    final nextPage = reset ? 1 : state.page + 1;

    state = state.copyWith(
      query: query,
      isLoading: reset,
      isLoadingMore: !reset,
      offers: reset ? const [] : state.offers,
      clearError: true,
    );

    try {
      await ref.read(savedAddressesProvider.notifier).ensureLoaded();
      if (!ref.mounted || requestId != _requestId) return;

      final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
      final result = await _discoveryService.searchOffers(
        query: query,
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
            totalCount: page.count,
            hasMore: page.hasMore,
            isLoading: false,
            isLoadingMore: false,
            clearError: true,
          );
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to search offers', error, stackTrace);
      if (!ref.mounted || requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Could not search offers. Please try again.',
      );
    }
  }
}
