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

@ProviderFor(userAddressService)
final userAddressServiceProvider = UserAddressServiceProvider._();

final class UserAddressServiceProvider extends $FunctionalProvider<
    UserAddressService,
    UserAddressService,
    UserAddressService> with $Provider<UserAddressService> {
  UserAddressServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userAddressServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userAddressServiceHash();

  @$internal
  @override
  $ProviderElement<UserAddressService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserAddressService create(Ref ref) {
    return userAddressService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserAddressService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserAddressService>(value),
    );
  }
}

String _$userAddressServiceHash() =>
    r'7fa53cbf7c3f073482fd9f55ab024e4deb343536';

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

String _$savedAddressesHash() => r'e5fe454e4452df28f7de56c6a87db8c676e6f769';

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
