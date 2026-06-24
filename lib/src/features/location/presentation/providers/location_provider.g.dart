// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Location)
final locationProvider = LocationProvider._();

final class LocationProvider
    extends $NotifierProvider<Location, LocationState> {
  LocationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationHash();

  @$internal
  @override
  Location create() => Location();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationState>(value),
    );
  }
}

String _$locationHash() => r'3ab0035c97da348f03c9495c8844acfdcf2c846e';

abstract class _$Location extends $Notifier<LocationState> {
  LocationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LocationState, LocationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<LocationState, LocationState>,
        LocationState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
