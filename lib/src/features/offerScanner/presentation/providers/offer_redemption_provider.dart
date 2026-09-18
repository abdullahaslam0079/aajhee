import 'package:aajhee/src/features/availedOffers/presentation/providers/availed_offers_provider.dart';
import 'package:aajhee/src/features/home/data/models/offer_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/branch_offers_provider.dart';
import 'package:aajhee/src/features/offerScanner/data/services/offer_service.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_payment_preview.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_qr_codec.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_scanner_session.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_usage_status.dart';
import 'package:aajhee/src/features/offerScanner/presentation/providers/offer_usage_status_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'offer_redemption_provider.g.dart';

enum OfferRedemptionStatus {
  idle,
  processing,
  awaitingBillAmount,
  awaitingConfirmation,
  redeemed,
  error,
}

class OfferRedemptionState {
  const OfferRedemptionState({
    this.status = OfferRedemptionStatus.idle,
    this.selectedOffer,
    this.branchId,
    this.branchName,
    this.branchAddress,
    this.redeemedOffer,
    this.usageStatus,
    this.paymentPreview,
    this.qrCode,
    this.errorMessage,
  });

  final OfferRedemptionStatus status;
  final OfferModel? selectedOffer;
  final int? branchId;
  final String? branchName;
  final String? branchAddress;
  final OfferModel? redeemedOffer;
  final OfferUsageStatus? usageStatus;
  final OfferPaymentPreview? paymentPreview;
  final String? qrCode;
  final String? errorMessage;

  bool get isBusy => status == OfferRedemptionStatus.processing;

  bool get needsBillAmount =>
      status == OfferRedemptionStatus.awaitingBillAmount;

  bool get needsConfirmation =>
      status == OfferRedemptionStatus.awaitingConfirmation;

  OfferRedemptionState copyWith({
    OfferRedemptionStatus? status,
    OfferModel? selectedOffer,
    int? branchId,
    String? branchName,
    String? branchAddress,
    OfferModel? redeemedOffer,
    OfferUsageStatus? usageStatus,
    OfferPaymentPreview? paymentPreview,
    String? qrCode,
    String? errorMessage,
    bool clearError = false,
    bool clearRedeemedOffer = false,
    bool clearUsageStatus = false,
    bool clearPaymentPreview = false,
  }) {
    return OfferRedemptionState(
      status: status ?? this.status,
      selectedOffer: selectedOffer ?? this.selectedOffer,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      branchAddress: branchAddress ?? this.branchAddress,
      redeemedOffer:
          clearRedeemedOffer ? null : (redeemedOffer ?? this.redeemedOffer),
      usageStatus:
          clearUsageStatus ? null : (usageStatus ?? this.usageStatus),
      paymentPreview: clearPaymentPreview
          ? null
          : (paymentPreview ?? this.paymentPreview),
      qrCode: qrCode ?? this.qrCode,
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
    await resolveScannedCode(code);
  }

  Future<void> resolveScannedCode(String code) async {
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

    final branchId = _resolveBranchId(
      offer: state.selectedOffer,
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

    final byQrResult = await service.fetchOfferByQr(
      qrCode: qrCode,
      branchId: branchId,
    );
    if (!ref.mounted) return;

    final resolved = byQrResult.fold(
      (failure) {
        state = state.copyWith(
          status: OfferRedemptionStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (value) => value,
    );
    if (resolved == null) return;

    final offer = resolved.offer;
    final selectedOffer = state.selectedOffer;
    if (selectedOffer != null &&
        selectedOffer.id != offer.id &&
        service.matchOfferFromCode(code, [selectedOffer]) == null) {
      state = state.copyWith(
        status: OfferRedemptionStatus.error,
        errorMessage:
            'This QR code does not match the selected offer. Please scan the correct code.',
      );
      return;
    }

    if (!resolved.canAvail) {
      final usageStatus = resolved.usage != null
          ? OfferUsageStatus.fromUsageResult(offer, resolved.usage!)
          : OfferUsageStatus.fromOffer(offer);
      state = state.copyWith(
        status: OfferRedemptionStatus.error,
        errorMessage: resolved.usage?.message?.isNotEmpty == true
            ? resolved.usage!.message!
            : usageStatus.availabilityLabel,
      );
      return;
    }

    final payment = resolved.payment;
    state = state.copyWith(
      selectedOffer: offer,
      branchId: resolved.branch.id,
      branchName: resolved.branch.name,
      branchAddress: resolved.branch.formattedAddress,
      qrCode: qrCode,
      paymentPreview: payment,
      status: payment.requiresBillAmount && !payment.isComplete
          ? OfferRedemptionStatus.awaitingBillAmount
          : OfferRedemptionStatus.awaitingConfirmation,
    );
  }

  Future<void> submitBillAmount(String rawAmount) async {
    if (state.isBusy || !ref.mounted) return;

    final offer = state.selectedOffer;
    final branchId = state.branchId;
    final qrCode = state.qrCode;
    if (offer == null || branchId == null || qrCode == null) return;

    final billAmount = double.tryParse(rawAmount.replaceAll(',', '.').trim());
    if (billAmount == null || billAmount <= 0) {
      state = state.copyWith(
        status: OfferRedemptionStatus.error,
        errorMessage: 'Enter a valid bill amount greater than zero.',
      );
      return;
    }

    state = state.copyWith(
      status: OfferRedemptionStatus.processing,
      clearError: true,
    );

    final service = ref.read(offerServiceProvider);
    final previewResult = await service.fetchPaymentPreview(
      offerId: offer.id,
      billAmount: billAmount,
    );
    if (!ref.mounted) return;

    previewResult.fold(
      (failure) {
        state = state.copyWith(
          status: OfferRedemptionStatus.awaitingBillAmount,
          errorMessage: failure.message,
        );
      },
      (payment) {
        state = state.copyWith(
          status: OfferRedemptionStatus.awaitingConfirmation,
          paymentPreview: payment,
          clearError: true,
        );
      },
    );
  }

  Future<void> confirmAvail() async {
    if (state.isBusy || !ref.mounted) return;

    final offer = state.selectedOffer;
    final branchId = state.branchId;
    final qrCode = state.qrCode;
    final payment = state.paymentPreview;
    if (offer == null || branchId == null || qrCode == null || payment == null) {
      return;
    }

    if (!payment.isComplete) {
      state = state.copyWith(
        status: OfferRedemptionStatus.awaitingBillAmount,
        errorMessage: 'Enter your bill total to calculate what you pay.',
      );
      return;
    }

    state = state.copyWith(
      status: OfferRedemptionStatus.processing,
      clearError: true,
    );

    final service = ref.read(offerServiceProvider);
    final availResult = await service.availOffer(
      offerId: offer.id,
      branchId: branchId,
      qrCode: qrCode,
      billAmount: payment.billAmount,
    );
    if (!ref.mounted) return;

    final result = availResult.fold(
      (failure) {
        state = state.copyWith(
          status: OfferRedemptionStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (value) => value,
    );
    if (result == null) return;

    ref.invalidate(branchOffersProvider(branchId));
    ref.invalidate(offerUsageStatusProvider(offer));
    ref.invalidate(availedOffersProvider);

    final updatedUsageStatus =
        OfferUsageStatus.fromUsageResult(offer, result.usage);
    state = state.copyWith(
      status: OfferRedemptionStatus.redeemed,
      redeemedOffer: offer,
      usageStatus: updatedUsageStatus,
      paymentPreview: result.payment,
    );
  }

  int? _resolveBranchId({
    OfferModel? offer,
    required int? sessionBranchId,
    required int? payloadBranchId,
  }) {
    final candidates = [
      sessionBranchId,
      payloadBranchId,
    ].whereType<int>();

    if (offer != null) {
      final matching = candidates.where(offer.branchIds.contains);
      if (matching.isNotEmpty) return matching.first;
      if (offer.branchIds.length == 1) return offer.branchIds.first;
    } else if (candidates.isNotEmpty) {
      return candidates.first;
    }

    return null;
  }

  void resetScan() {
    if (!ref.mounted) return;
    state = state.copyWith(
      status: OfferRedemptionStatus.idle,
      clearError: true,
      clearRedeemedOffer: true,
      clearUsageStatus: true,
      clearPaymentPreview: true,
      qrCode: null,
    );
  }

  void cancelConfirmation() {
    if (!ref.mounted) return;
    resetScan();
  }
}
