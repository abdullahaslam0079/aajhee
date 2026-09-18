import 'package:flutter/material.dart';
import 'package:aajhee/src/features/auth/presentation/providers/session_provider.dart';
import 'package:aajhee/src/features/notifications/data/services/notification_service.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_preferences_provider.g.dart';

/// Persisted theme choice. Default is [system] (follow device).
enum AppThemePreference {
  system,
  light,
  dark;

  String get apiValue => name;

  String get label => switch (this) {
        AppThemePreference.system => 'System default',
        AppThemePreference.light => 'Light',
        AppThemePreference.dark => 'Dark',
      };

  ThemeMode get themeMode => switch (this) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      };

  static AppThemePreference fromApi(String? value) {
    return AppThemePreference.values.firstWhere(
      (item) => item.apiValue == value,
      orElse: () => AppThemePreference.system,
    );
  }
}

class ThemePreferencesState {
  const ThemePreferencesState({
    this.preference = AppThemePreference.system,
    this.isSaving = false,
  });

  final AppThemePreference preference;
  final bool isSaving;

  ThemeMode get themeMode => preference.themeMode;

  ThemePreferencesState copyWith({
    AppThemePreference? preference,
    bool? isSaving,
  }) {
    return ThemePreferencesState(
      preference: preference ?? this.preference,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

@Riverpod(keepAlive: true)
class ThemePreferences extends _$ThemePreferences {
  static const _storageKey = 'theme_preference';

  NotificationService get _service => ref.read(notificationServiceProvider);

  @override
  ThemePreferencesState build() {
    ref.listen(sessionProvider, (previous, next) {
      if (next.status == SessionStatus.authenticated) {
        Future.microtask(syncFromBackend);
      }
    });

    Future.microtask(_hydrateLocal);

    final session = ref.watch(sessionProvider);
    if (session.status == SessionStatus.authenticated) {
      Future.microtask(syncFromBackend);
    }

    return const ThemePreferencesState();
  }

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> _hydrateLocal() async {
    final prefs = await _prefs;
    final stored = prefs.getString(_storageKey);
    if (stored == null) return;
    final preference = AppThemePreference.fromApi(stored);
    if (preference != state.preference) {
      state = state.copyWith(preference: preference);
    }
  }

  Future<void> _persistLocal(AppThemePreference preference) async {
    final prefs = await _prefs;
    await prefs.setString(_storageKey, preference.apiValue);
  }

  /// Pull saved theme after login / session restore.
  Future<void> syncFromBackend() async {
    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) return;

    final result = await _service.fetchThemePreference();
    await result.fold(
      (_) async {},
      (value) async {
        final preference = AppThemePreference.fromApi(value);
        await _persistLocal(preference);
        state = state.copyWith(preference: preference);
      },
    );
  }

  Future<void> setPreference(AppThemePreference preference) async {
    final previous = state.preference;
    state = state.copyWith(preference: preference, isSaving: true);
    await _persistLocal(preference);

    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) {
      state = state.copyWith(isSaving: false);
      return;
    }

    final result = await _service.setThemePreference(preference.apiValue);
    result.fold(
      (_) async {
        await _persistLocal(previous);
        state = state.copyWith(preference: previous, isSaving: false);
      },
      (value) {
        final saved = AppThemePreference.fromApi(value);
        state = state.copyWith(preference: saved, isSaving: false);
      },
    );
  }
}
