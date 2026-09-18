import 'package:aajhee/src/features/auth/presentation/providers/session_provider.dart';
import 'package:aajhee/src/features/home/data/models/offer_model.dart';
import 'package:aajhee/src/features/offerScanner/domain/offer_usage_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'offer_usage_status_provider.g.dart';

@Riverpod(keepAlive: false)
OfferUsageStatus offerUsageStatus(Ref ref, OfferModel offer) {
  ref.watch(sessionProvider);
  return OfferUsageStatus.fromOffer(offer);
}
