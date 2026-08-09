import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'branch_offers_provider.g.dart';

class BranchOffersState {
  const BranchOffersState({
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

  BranchOffersState copyWith({
    List<OfferModel>? offers,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BranchOffersState(
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
class BranchOffers extends _$BranchOffers {
  static const _pageSize = 20;
  int _requestId = 0;

  @override
  BranchOffersState build(int branchId) {
    ref.watch(sessionProvider);
    Future.microtask(load);
    return const BranchOffersState(isLoading: true);
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

    final result = await ref.read(discoveryServiceProvider).getBranchOffers(
          branchId,
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
