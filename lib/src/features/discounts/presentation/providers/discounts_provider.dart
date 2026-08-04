import 'package:goluto/src/features/discounts/data/services/engagement_service.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discounts_provider.g.dart';

class DiscountsState {
  const DiscountsState({
    this.offers = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<OfferModel> offers;
  final bool isLoading;
  final String? errorMessage;

  DiscountsState copyWith({
    List<OfferModel>? offers,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DiscountsState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
EngagementService engagementService(Ref ref) {
  return EngagementService.instance;
}

@Riverpod(keepAlive: true)
class DiscountsFeed extends _$DiscountsFeed {
  late final EngagementService _engagementService;

  @override
  DiscountsState build() {
    _engagementService = ref.read(engagementServiceProvider);
    return const DiscountsState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await ref.read(savedAddressesProvider.notifier).ensureLoaded();
      if (!ref.mounted) return;

      final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
      final result = await _engagementService.getDiscountsFeed(
        addressId: addressId,
      );
      if (!ref.mounted) return;

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
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load discounts feed', error, stackTrace);
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load discounts. Please try again.',
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
