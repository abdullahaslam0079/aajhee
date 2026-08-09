// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemePreferences)
final themePreferencesProvider = ThemePreferencesProvider._();

final class ThemePreferencesProvider
    extends $NotifierProvider<ThemePreferences, ThemePreferencesState> {
  ThemePreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'themePreferencesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$themePreferencesHash();

  @$internal
  @override
  ThemePreferences create() => ThemePreferences();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemePreferencesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemePreferencesState>(value),
    );
  }
}

String _$themePreferencesHash() => r'c09d725a16850a3e03fc793b56b28431c50ac5e0';

abstract class _$ThemePreferences extends $Notifier<ThemePreferencesState> {
  ThemePreferencesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemePreferencesState, ThemePreferencesState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ThemePreferencesState, ThemePreferencesState>,
        ThemePreferencesState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
