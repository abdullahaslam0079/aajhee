import 'dart:convert';

class ScannedOfferPayload {
  const ScannedOfferPayload({
    required this.offerId,
    required this.qrCode,
    this.branchId,
  });

  final int offerId;
  final String qrCode;
  final int? branchId;

  static ScannedOfferPayload? parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('GOLUTO:')) {
      try {
        final json =
            jsonDecode(trimmed.substring('GOLUTO:'.length)) as Map<String, dynamic>;
        final offerIdRaw = json['offerId'];
        final offerId = offerIdRaw is int
            ? offerIdRaw
            : int.tryParse('$offerIdRaw');
        final qrCode = (json['qr_code'] ?? json['token'])?.toString();
        if (offerId == null || qrCode == null || qrCode.isEmpty) return null;

        final branchIdRaw = json['branch_id'] ?? json['branchId'];
        final branchId = branchIdRaw is int
            ? branchIdRaw
            : int.tryParse('$branchIdRaw');

        return ScannedOfferPayload(
          offerId: offerId,
          qrCode: qrCode,
          branchId: branchId,
        );
      } catch (_) {
        return null;
      }
    }

    return null;
  }
}
