import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'branch_offers_provider.g.dart';

class BranchOffersState {
  const BranchOffersState({
    this.offers = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<OfferModel> offers;
  final bool isLoading;
  final String? errorMessage;

  BranchOffersState copyWith({
    List<OfferModel>? offers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BranchOffersState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@Riverpod(keepAlive: false)
class BranchOffers extends _$BranchOffers {
  @override
  BranchOffersState build(int branchId) {
    Future.microtask(load);
    return const BranchOffersState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result =
        await ref.read(discoveryServiceProvider).getBranchOffers(branchId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (offers) {
        state = state.copyWith(
          offers: offers,
          isLoading: false,
          errorMessage: null,
        );
      },
    );
  }
}
