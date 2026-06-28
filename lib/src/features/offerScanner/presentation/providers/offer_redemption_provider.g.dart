// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_redemption_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(offerService)
final offerServiceProvider = OfferServiceProvider._();

final class OfferServiceProvider
    extends $FunctionalProvider<OfferService, OfferService, OfferService>
    with $Provider<OfferService> {
  OfferServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'offerServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$offerServiceHash();

  @$internal
  @override
  $ProviderElement<OfferService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OfferService create(Ref ref) {
    return offerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfferService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfferService>(value),
    );
  }
}

String _$offerServiceHash() => r'776944779189981a2586c336d0b725d55bd8ae06';

@ProviderFor(OfferRedemption)
final offerRedemptionProvider = OfferRedemptionFamily._();

final class OfferRedemptionProvider
    extends $NotifierProvider<OfferRedemption, OfferRedemptionState> {
  OfferRedemptionProvider._(
      {required OfferRedemptionFamily super.from,
      required OfferScannerSession super.argument})
      : super(
          retry: null,
          name: r'offerRedemptionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$offerRedemptionHash();

  @override
  String toString() {
    return r'offerRedemptionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OfferRedemption create() => OfferRedemption();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfferRedemptionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfferRedemptionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OfferRedemptionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$offerRedemptionHash() => r'b9384e99abcea2f9381e7769a0abe166964f61f9';

final class OfferRedemptionFamily extends $Family
    with
        $ClassFamilyOverride<OfferRedemption, OfferRedemptionState,
            OfferRedemptionState, OfferRedemptionState, OfferScannerSession> {
  OfferRedemptionFamily._()
      : super(
          retry: null,
          name: r'offerRedemptionProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  OfferRedemptionProvider call(
    OfferScannerSession session,
  ) =>
      OfferRedemptionProvider._(argument: session, from: this);

  @override
  String toString() => r'offerRedemptionProvider';
}

abstract class _$OfferRedemption extends $Notifier<OfferRedemptionState> {
  late final _$args = ref.$arg as OfferScannerSession;
  OfferScannerSession get session => _$args;

  OfferRedemptionState build(
    OfferScannerSession session,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OfferRedemptionState, OfferRedemptionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<OfferRedemptionState, OfferRedemptionState>,
        OfferRedemptionState,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
