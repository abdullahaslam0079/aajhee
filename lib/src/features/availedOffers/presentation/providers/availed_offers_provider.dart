import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto/src/features/availedOffers/data/models/availed_offer_model.dart';
import 'package:goluto/src/features/offerScanner/presentation/providers/offer_redemption_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'availed_offers_provider.g.dart';

class AvailedOffersState {
  const AvailedOffersState({
    this.offers = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<AvailedOfferModel> offers;
  final bool isLoading;
  final String? errorMessage;

  AvailedOffersState copyWith({
    List<AvailedOfferModel>? offers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AvailedOffersState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@Riverpod(keepAlive: false)
class AvailedOffers extends _$AvailedOffers {
  @override
  AvailedOffersState build() {
    final session = ref.watch(sessionProvider);
    if (session.status != SessionStatus.authenticated) {
      return const AvailedOffersState();
    }

    Future.microtask(load);
    return const AvailedOffersState(isLoading: true);
  }

  Future<void> load() async {
    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) {
      state = const AvailedOffersState();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref.read(offerServiceProvider).fetchAvailedOffers();

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
