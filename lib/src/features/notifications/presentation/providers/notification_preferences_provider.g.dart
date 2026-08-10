// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationPreferences)
final notificationPreferencesProvider = NotificationPreferencesProvider._();

final class NotificationPreferencesProvider extends $NotifierProvider<
    NotificationPreferences, NotificationPreferencesState> {
  NotificationPreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationPreferencesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationPreferencesHash();

  @$internal
  @override
  NotificationPreferences create() => NotificationPreferences();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPreferencesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPreferencesState>(value),
    );
  }
}

String _$notificationPreferencesHash() =>
    r'e6949c0ba96db9847b234a875f974b35cdc479ea';

abstract class _$NotificationPreferences
    extends $Notifier<NotificationPreferencesState> {
  NotificationPreferencesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref
        as $Ref<NotificationPreferencesState, NotificationPreferencesState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<NotificationPreferencesState, NotificationPreferencesState>,
        NotificationPreferencesState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
