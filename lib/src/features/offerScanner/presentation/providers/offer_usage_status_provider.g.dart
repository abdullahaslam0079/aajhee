// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_usage_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(offerUsageStatus)
final offerUsageStatusProvider = OfferUsageStatusFamily._();

final class OfferUsageStatusProvider extends $FunctionalProvider<
    OfferUsageStatus,
    OfferUsageStatus,
    OfferUsageStatus> with $Provider<OfferUsageStatus> {
  OfferUsageStatusProvider._(
      {required OfferUsageStatusFamily super.from,
      required OfferModel super.argument})
      : super(
          retry: null,
          name: r'offerUsageStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$offerUsageStatusHash();

  @override
  String toString() {
    return r'offerUsageStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<OfferUsageStatus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OfferUsageStatus create(Ref ref) {
    final argument = this.argument as OfferModel;
    return offerUsageStatus(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfferUsageStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfferUsageStatus>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OfferUsageStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$offerUsageStatusHash() => r'1bcb0716f0e19d605acfffc0aa6ee0a9868f6bb3';

final class OfferUsageStatusFamily extends $Family
    with $FunctionalFamilyOverride<OfferUsageStatus, OfferModel> {
  OfferUsageStatusFamily._()
      : super(
          retry: null,
          name: r'offerUsageStatusProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  OfferUsageStatusProvider call(
    OfferModel offer,
  ) =>
      OfferUsageStatusProvider._(argument: offer, from: this);

  @override
  String toString() => r'offerUsageStatusProvider';
}
