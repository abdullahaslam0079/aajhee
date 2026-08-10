// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_offers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BranchOffers)
final branchOffersProvider = BranchOffersFamily._();

final class BranchOffersProvider
    extends $NotifierProvider<BranchOffers, BranchOffersState> {
  BranchOffersProvider._(
      {required BranchOffersFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'branchOffersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$branchOffersHash();

  @override
  String toString() {
    return r'branchOffersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BranchOffers create() => BranchOffers();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BranchOffersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BranchOffersState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BranchOffersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$branchOffersHash() => r'4cda22c6e03c98c2c278c7f59ec9e4ba138c2ebf';

final class BranchOffersFamily extends $Family
    with
        $ClassFamilyOverride<BranchOffers, BranchOffersState, BranchOffersState,
            BranchOffersState, int> {
  BranchOffersFamily._()
      : super(
          retry: null,
          name: r'branchOffersProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  BranchOffersProvider call(
    int branchId,
  ) =>
      BranchOffersProvider._(argument: branchId, from: this);

  @override
  String toString() => r'branchOffersProvider';
}

abstract class _$BranchOffers extends $Notifier<BranchOffersState> {
  late final _$args = ref.$arg as int;
  int get branchId => _$args;

  BranchOffersState build(
    int branchId,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BranchOffersState, BranchOffersState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<BranchOffersState, BranchOffersState>,
        BranchOffersState,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
