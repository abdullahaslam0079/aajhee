// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_addresses_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(addressGeocodingService)
final addressGeocodingServiceProvider = AddressGeocodingServiceProvider._();

final class AddressGeocodingServiceProvider extends $FunctionalProvider<
    AddressGeocodingService,
    AddressGeocodingService,
    AddressGeocodingService> with $Provider<AddressGeocodingService> {
  AddressGeocodingServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'addressGeocodingServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addressGeocodingServiceHash();

  @$internal
  @override
  $ProviderElement<AddressGeocodingService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AddressGeocodingService create(Ref ref) {
    return addressGeocodingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddressGeocodingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddressGeocodingService>(value),
    );
  }
}

String _$addressGeocodingServiceHash() =>
    r'9d0feb21bd1c81b3a806f3841ad50baec73f1bc0';

@ProviderFor(SavedAddresses)
final savedAddressesProvider = SavedAddressesProvider._();

final class SavedAddressesProvider
    extends $NotifierProvider<SavedAddresses, SavedAddressesState> {
  SavedAddressesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'savedAddressesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$savedAddressesHash();

  @$internal
  @override
  SavedAddresses create() => SavedAddresses();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedAddressesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedAddressesState>(value),
    );
  }
}

String _$savedAddressesHash() => r'1d0f0c62a09f1e29b8716567e39fe3947a5d87d2';

abstract class _$SavedAddresses extends $Notifier<SavedAddressesState> {
  SavedAddressesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SavedAddressesState, SavedAddressesState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SavedAddressesState, SavedAddressesState>,
        SavedAddressesState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
