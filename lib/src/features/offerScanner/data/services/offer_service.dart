import 'package:dio/dio.dart';
import 'package:aajhee/src/config/app_config.dart';
import 'package:aajhee/src/features/availedOffers/data/models/availed_offer_model.dart';
import 'package:aajhee/src/features/home/data/models/offer_model.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_by_qr_result.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_payment_preview.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_qr_codec.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_usage_result.dart';
import 'package:aajhee/src/utils/utils.dart';

class OfferAvailResult {
  const OfferAvailResult({
    required this.usage,
    required this.payment,
  });

  final OfferUsageResult usage;
  final OfferPaymentPreview payment;

  factory OfferAvailResult.fromJson(Map<String, dynamic> json) {
    return OfferAvailResult(
      usage: OfferUsageResult.fromJson(json),
      payment: OfferPaymentPreview.fromJson(
        json['payment'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class OfferService {
  OfferService._();
  static final OfferService instance = OfferService._();

  Dio get _dio => AppConfig.dio;

  FutureEither<OfferByQrResult> fetchOfferByQr({
    required String qrCode,
    required int branchId,
    double? billAmount,
  }) async {
    return runTask(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/offers/by-qr/$qrCode',
        queryParameters: {
          'branch_id': branchId,
          if (billAmount != null) 'bill_amount': billAmount.toStringAsFixed(2),
        },
      );
      return OfferByQrResult.fromJson(response.data ?? const {});
    }, requiresNetwork: true);
  }

  FutureEither<OfferPaymentPreview> fetchPaymentPreview({
    required int offerId,
    double? billAmount,
  }) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/offers/$offerId/payment-preview',
        data: {
          if (billAmount != null) 'bill_amount': billAmount.toStringAsFixed(2),
        },
      );
      final data = response.data ?? const {};
      return OfferPaymentPreview.fromJson(
        data['payment'] as Map<String, dynamic>? ?? const {},
      );
    }, requiresNetwork: true);
  }

  FutureEither<OfferAvailResult> availOffer({
    required int offerId,
    required int branchId,
    required String qrCode,
    double? billAmount,
  }) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/offers/$offerId/avail',
        data: {
          'branch_id': branchId,
          'qr_code': qrCode,
          if (billAmount != null) 'bill_amount': billAmount.toStringAsFixed(2),
        },
      );
      return OfferAvailResult.fromJson(response.data ?? const {});
    }, requiresNetwork: true);
  }

  FutureEither<void> scanOffer({
    required int offerId,
    required int branchId,
    required String qrCode,
    double? billAmount,
  }) async {
    return runTask(() async {
      await _dio.post<void>(
        '/api/offers/$offerId/scan',
        data: {
          'branch_id': branchId,
          'qr_code': qrCode,
          if (billAmount != null) 'bill_amount': billAmount.toStringAsFixed(2),
        },
      );
    }, requiresNetwork: true);
  }

  FutureEither<OfferUsageResult> fetchOfferUsage({
    required int offerId,
  }) async {
    return runTask(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/offers/$offerId/usage',
      );
      return OfferUsageResult.fromJson(response.data ?? const {});
    }, requiresNetwork: true);
  }

  FutureEither<OfferAvailResult> redeemOffer({
    required int offerId,
    required int branchId,
    required String qrCode,
    double? billAmount,
  }) async {
    return availOffer(
      offerId: offerId,
      branchId: branchId,
      qrCode: qrCode,
      billAmount: billAmount,
    );
  }

  FutureEither<PaginatedPage<AvailedOfferModel>> fetchAvailedOffers({
    int page = 1,
    int pageSize = 20,
  }) async {
    return runTask(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/user/offers/availed',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      final data = response.data;
      if (data == null) {
        return PaginatedPage.empty<AvailedOfferModel>(pageSize: pageSize);
      }
      return PaginatedPage.fromJson(data, AvailedOfferModel.fromJson);
    }, requiresNetwork: true);
  }

  FutureEither<OfferModel?> findOfferByScannedCode(
    String code, {
    String? addressId,
    int? branchId,
  }) async {
    return runTask(() async {
      final qrCode = extractQrCode(code);
      if (qrCode == null) return null;

      final payload = ScannedOfferPayload.parse(code);
      final resolvedBranchId = branchId ?? payload?.branchId;
      if (resolvedBranchId == null) return null;

      final result = await fetchOfferByQr(
        qrCode: qrCode,
        branchId: resolvedBranchId,
      );
      return result.fold(
        (_) => null,
        (value) => value.offer,
      );
    }, requiresNetwork: true);
  }

  OfferModel? matchOfferFromCode(String code, List<OfferModel> offers) {
    final payload = ScannedOfferPayload.parse(code);
    if (payload != null) {
      for (final offer in offers) {
        if (offer.id == payload.offerId && offer.qrCode == payload.qrCode) {
          return offer;
        }
      }
      for (final offer in offers) {
        if (offer.id == payload.offerId) return offer;
      }
      return null;
    }

    final trimmed = code.trim();
    if (trimmed.isEmpty) return null;

    for (final offer in offers) {
      if (offer.qrCode == trimmed) return offer;
    }

    final offerId = int.tryParse(trimmed);
    if (offerId != null) {
      for (final offer in offers) {
        if (offer.id == offerId) return offer;
      }
    }

    return null;
  }

  String? extractQrCode(String code) {
    final payload = ScannedOfferPayload.parse(code);
    if (payload != null) return payload.qrCode;

    final trimmed = code.trim();
    if (trimmed.isEmpty) return null;

    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (uuidPattern.hasMatch(trimmed)) return trimmed;
    return null;
  }
}
