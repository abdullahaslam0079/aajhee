import 'package:aajhee/src/features/home/data/models/offer_model.dart';

class OfferScannerSession {
  const OfferScannerSession({
    this.offer,
    this.branchId,
    this.navigateToBranchOnSuccess = false,
  });

  final OfferModel? offer;
  final int? branchId;

  /// When true (FAB quick scan), navigates to the redeemed offer's branch
  /// after a successful redemption instead of returning to the previous screen.
  final bool navigateToBranchOnSuccess;

  @override
  bool operator ==(Object other) {
    return other is OfferScannerSession &&
        other.offer?.id == offer?.id &&
        other.branchId == branchId &&
        other.navigateToBranchOnSuccess == navigateToBranchOnSuccess;
  }

  @override
  int get hashCode =>
      Object.hash(offer?.id, branchId, navigateToBranchOnSuccess);
}
