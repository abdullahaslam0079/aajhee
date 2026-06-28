import 'package:dio/dio.dart';
import 'package:goluto/src/config/app_config.dart';
import 'package:goluto/src/features/availedOffers/data/models/availed_offer_model.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/offerScanner/domain/offer_qr_codec.dart';
import 'package:goluto/src/features/offerScanner/domain/offer_usage_result.dart';
import 'package:goluto/src/utils/utils.dart';

class OfferService {
  OfferService._();
  static final OfferService instance = OfferService._();

  Dio get _dio => AppConfig.dio;

  FutureEither<void> scanOffer({
    required int offerId,
    required int branchId,
    required String qrCode,
  }) async {
    return runTask(() async {
      await _dio.post<void>(
        '/api/offers/$offerId/scan',
        data: {
          'branch_id': branchId,
          'qr_code': qrCode,
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

  FutureEither<OfferUsageResult> redeemOffer({
    required int offerId,
    required int branchId,
    required String qrCode,
  }) async {
    return runTask(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/offers/$offerId/redeem',
        data: {
          'branch_id': branchId,
          'qr_code': qrCode,
        },
      );
      return OfferUsageResult.fromJson(response.data ?? const {});
    }, requiresNetwork: true);
  }

  FutureEither<List<AvailedOfferModel>> fetchAvailedOffers() async {
    return runTask(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/user/offers/availed',
      );
      final data = response.data ?? const {};
      final results = data['results'] as List<dynamic>? ?? const [];
      return results
          .map(
            (item) => AvailedOfferModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }, requiresNetwork: true);
  }

  FutureEither<OfferModel?> findOfferByScannedCode(String code) async {
    return runTask(() async {
      final response = await _dio.get<List<dynamic>>('/api/offers');
      final offers = (response.data ?? const [])
          .map((item) => OfferModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return matchOfferFromCode(code, offers);
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
