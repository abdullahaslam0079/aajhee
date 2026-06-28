import 'package:goluto/src/features/availedOffers/presentation/providers/availed_offers_provider.dart';
import 'package:goluto/src/features/home/presentation/providers/branch_offers_provider.dart';
import 'package:goluto/src/features/offerScanner/data/services/offer_service.dart';
import 'package:goluto/src/features/offerScanner/domain/offer_qr_codec.dart';
import 'package:goluto/src/features/offerScanner/domain/offer_scanner_session.dart';
import 'package:goluto/src/features/offerScanner/domain/offer_usage_status.dart';
import 'package:goluto/src/features/offerScanner/presentation/providers/offer_usage_status_provider.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'offer_redemption_provider.g.dart';

enum OfferRedemptionStatus {
  idle,
  processing,
  redeemed,
  error,
}

class OfferRedemptionState {
  const OfferRedemptionState({
    this.status = OfferRedemptionStatus.idle,
    this.selectedOffer,
    this.branchId,
    this.redeemedOffer,
    this.usageStatus,
    this.errorMessage,
  });

  final OfferRedemptionStatus status;
  final OfferModel? selectedOffer;
  final int? branchId;
  final OfferModel? redeemedOffer;
  final OfferUsageStatus? usageStatus;
  final String? errorMessage;

  bool get isBusy => status == OfferRedemptionStatus.processing;

  OfferRedemptionState copyWith({
    OfferRedemptionStatus? status,
    OfferModel? selectedOffer,
    int? branchId,
    OfferModel? redeemedOffer,
    OfferUsageStatus? usageStatus,
    String? errorMessage,
    bool clearError = false,
    bool clearRedeemedOffer = false,
    bool clearUsageStatus = false,
  }) {
    return OfferRedemptionState(
      status: status ?? this.status,
      selectedOffer: selectedOffer ?? this.selectedOffer,
      branchId: branchId ?? this.branchId,
      redeemedOffer:
          clearRedeemedOffer ? null : (redeemedOffer ?? this.redeemedOffer),
      usageStatus:
          clearUsageStatus ? null : (usageStatus ?? this.usageStatus),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@Riverpod(keepAlive: false)
OfferService offerService(Ref ref) {
  return OfferService.instance;
}

@Riverpod(keepAlive: false)
class OfferRedemption extends _$OfferRedemption {
  @override
  OfferRedemptionState build(OfferScannerSession session) {
    return OfferRedemptionState(
      selectedOffer: session.offer,
      branchId: session.branchId,
    );
  }

  Future<void> redeemScannedCode(String code) async {
    if (state.isBusy || !ref.mounted) return;

    state = state.copyWith(
      status: OfferRedemptionStatus.processing,
      clearError: true,
    );

    final service = ref.read(offerServiceProvider);
    final payload = ScannedOfferPayload.parse(code);
    final qrCode = payload?.qrCode ?? service.extractQrCode(code);
    if (qrCode == null || qrCode.isEmpty) {
      state = state.copyWith(
        status: OfferRedemptionStatus.error,
        errorMessage: 'Could not read a valid QR code. Please try again.',
      );
      return;
    }

    OfferModel? offer = state.selectedOffer;

    if (offer != null) {
      final matchesSelected = service.matchOfferFromCode(code, [offer]) != null;
      if (!matchesSelected) {
        if (!ref.mounted) return;
        state = state.copyWith(
          status: OfferRedemptionStatus.error,
          errorMessage:
              'This QR code does not match the selected offer. Please scan the correct code.',
        );
        return;
      }
    } else {
      final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
      final lookupResult = await service.findOfferByScannedCode(
        code,
        addressId: addressId,
      );
      if (!ref.mounted) return;

      final resolvedOffer = lookupResult.fold(
        (failure) {
          state = state.copyWith(
            status: OfferRedemptionStatus.error,
            errorMessage: failure.message,
          );
          return null;
        },
        (value) => value,
      );
      if (resolvedOffer == null) {
        if (state.status != OfferRedemptionStatus.error) {
          state = state.copyWith(
            status: OfferRedemptionStatus.error,
            errorMessage: 'No offer found for this QR code.',
          );
        }
        return;
      }
      offer = resolvedOffer;
    }

    final branchId = _resolveBranchId(
      offer: offer,
      sessionBranchId: state.branchId,
      payloadBranchId: payload?.branchId,
    );
    if (branchId == null) {
      state = state.copyWith(
        status: OfferRedemptionStatus.error,
        errorMessage:
            'Could not determine which branch this QR code belongs to.',
      );
      return;
    }

    if (!offer.branchIds.contains(branchId)) {
      state = state.copyWith(
        status: OfferRedemptionStatus.error,
        errorMessage: 'This offer is not available at this branch.',
      );
      return;
    }

    if (offer.qrCode.isNotEmpty && offer.qrCode != qrCode) {
      state = state.copyWith(
        status: OfferRedemptionStatus.error,
        errorMessage: 'Invalid QR code for this offer.',
      );
      return;
    }

    final usageCheck = await service.fetchOfferUsage(offerId: offer.id);
    if (!ref.mounted) return;

    final usageResult = usageCheck.fold(
      (failure) {
        state = state.copyWith(
          status: OfferRedemptionStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (value) => value,
    );
    if (usageResult == null) return;

    final usageStatus = OfferUsageStatus.fromUsageResult(offer, usageResult);
    if (!usageStatus.isAvailable) {
      state = state.copyWith(
        status: OfferRedemptionStatus.error,
        errorMessage: (usageResult.message?.isNotEmpty ?? false)
            ? usageResult.message!
            : 'You have reached the usage limit for this offer. ${usageStatus.usageSummary}.',
      );
      return;
    }

    final scanResult = await service.scanOffer(
      offerId: offer.id,
      branchId: branchId,
      qrCode: qrCode,
    );
    if (!ref.mounted) return;

    final scanFailure = scanResult.fold((failure) => failure, (_) => null);
    if (scanFailure != null) {
      state = state.copyWith(
        status: OfferRedemptionStatus.error,
        errorMessage: scanFailure.message,
      );
      return;
    }

    final redeemResult = await service.redeemOffer(
      offerId: offer.id,
      branchId: branchId,
      qrCode: qrCode,
    );
    if (!ref.mounted) return;

    final redeemedUsage = redeemResult.fold(
      (failure) {
        state = state.copyWith(
          status: OfferRedemptionStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (value) => value,
    );
    if (redeemedUsage == null) return;

    ref.invalidate(branchOffersProvider(branchId));
    ref.invalidate(offerUsageStatusProvider(offer));
    ref.invalidate(availedOffersProvider);

    final updatedUsageStatus =
        OfferUsageStatus.fromUsageResult(offer, redeemedUsage);
    state = state.copyWith(
      status: OfferRedemptionStatus.redeemed,
      redeemedOffer: offer,
      selectedOffer: offer,
      branchId: branchId,
      usageStatus: updatedUsageStatus,
    );
  }

  int? _resolveBranchId({
    required OfferModel offer,
    required int? sessionBranchId,
    required int? payloadBranchId,
  }) {
    final candidates = [
      sessionBranchId,
      payloadBranchId,
    ].whereType<int>().where(offer.branchIds.contains);

    if (candidates.isNotEmpty) return candidates.first;

    if (offer.branchIds.length == 1) return offer.branchIds.first;

    return null;
  }

  void resetScan() {
    if (!ref.mounted) return;
    state = state.copyWith(
      status: OfferRedemptionStatus.idle,
      clearError: true,
      clearRedeemedOffer: true,
      clearUsageStatus: true,
    );
  }
}
