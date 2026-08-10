// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availed_offers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AvailedOffers)
final availedOffersProvider = AvailedOffersProvider._();

final class AvailedOffersProvider
    extends $NotifierProvider<AvailedOffers, AvailedOffersState> {
  AvailedOffersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'availedOffersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$availedOffersHash();

  @$internal
  @override
  AvailedOffers create() => AvailedOffers();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AvailedOffersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AvailedOffersState>(value),
    );
  }
}

String _$availedOffersHash() => r'dcb1351eca37cfbe4b0fa624aca9780d2e841f43';

abstract class _$AvailedOffers extends $Notifier<AvailedOffersState> {
  AvailedOffersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AvailedOffersState, AvailedOffersState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AvailedOffersState, AvailedOffersState>,
        AvailedOffersState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
