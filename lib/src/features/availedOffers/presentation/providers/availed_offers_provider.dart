import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto/src/features/availedOffers/data/models/availed_offer_model.dart';
import 'package:goluto/src/features/offerScanner/presentation/providers/offer_redemption_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'availed_offers_provider.g.dart';

class AvailedOffersState {
  const AvailedOffersState({
    this.offers = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<AvailedOfferModel> offers;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  AvailedOffersState copyWith({
    List<AvailedOfferModel>? offers,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AvailedOffersState(
      offers: offers ?? this.offers,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@Riverpod(keepAlive: false)
class AvailedOffers extends _$AvailedOffers {
  static const _pageSize = 20;
  int _requestId = 0;

  @override
  AvailedOffersState build() {
    final session = ref.watch(sessionProvider);
    if (session.status != SessionStatus.authenticated) {
      return const AvailedOffersState();
    }

    Future.microtask(load);
    return const AvailedOffersState(isLoading: true);
  }

  Future<void> load() => _fetch(reset: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    await _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset}) async {
    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) {
      state = const AvailedOffersState();
      return;
    }

    final requestId = ++_requestId;
    final nextPage = reset ? 1 : state.page + 1;

    state = state.copyWith(
      isLoading: reset,
      isLoadingMore: !reset,
      offers: reset ? const [] : state.offers,
      clearError: true,
    );

    final result = await ref.read(offerServiceProvider).fetchAvailedOffers(
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
        final offers =
            reset ? page.results : [...state.offers, ...page.results];
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
  }
}
