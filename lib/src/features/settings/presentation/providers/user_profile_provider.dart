import 'dart:async';
import 'dart:convert';

import 'package:goluto/src/features/auth/domain/entities/user.dart';
import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto/src/features/settings/domain/entities/user_profile.dart'
    as entities;
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_provider.g.dart';

class UserProfileState {
  const UserProfileState({
    this.profile = entities.UserProfile.empty,
    this.isLoading = false,
  });

  final entities.UserProfile profile;
  final bool isLoading;

  UserProfileState copyWith({
    entities.UserProfile? profile,
    bool? isLoading,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@Riverpod(keepAlive: true)
class UserProfile extends _$UserProfile {
  static const _storageKey = 'user_profile';

  SharedPreferences? _prefs;

  @override
  UserProfileState build() {
    ref.listen(sessionProvider, (previous, next) {
      if (next.status == SessionStatus.authenticated && next.user != null) {
        final userChanged = previous?.user?.id != next.user?.id;
        unawaited(_hydrateFromSession(next.user!, overwrite: userChanged));
      } else if (next.status == SessionStatus.unauthenticated) {
        unawaited(_clearProfile());
      }
    });

    unawaited(_load());
    return const UserProfileState(isLoading: true);
  }

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _load() async {
    try {
      final prefs = await _preferences;
      final raw = prefs.getString(_storageKey);
      final session = ref.read(sessionProvider);

      if (raw != null && raw.isNotEmpty) {
        final stored = entities.UserProfile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );

        if (session.status == SessionStatus.authenticated &&
            session.user != null &&
            stored.email != session.user!.email) {
          await _hydrateFromSession(session.user!, overwrite: true);
          return;
        }

        state = UserProfileState(profile: stored);
        return;
      }

      if (session.status == SessionStatus.authenticated &&
          session.user != null) {
        await _hydrateFromSession(session.user!, overwrite: true);
        return;
      }

      state = const UserProfileState();
    } catch (_) {
      state = const UserProfileState();
    }
  }

  Future<void> syncFromAuthUser(AppUser user) async {
    await _hydrateFromSession(user, overwrite: true);
  }

  Future<void> _hydrateFromSession(
    AppUser user, {
    required bool overwrite,
  }) async {
    final prefs = await _preferences;
    final raw = prefs.getString(_storageKey);

    if (!overwrite && raw != null && raw.isNotEmpty) {
      final stored = entities.UserProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (stored.email == user.email) {
        state = UserProfileState(profile: stored);
        return;
      }
    }

    final profile = entities.UserProfile.fromAppUser(user);
    await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
    state = UserProfileState(profile: profile);
  }

  Future<void> _clearProfile() async {
    final prefs = await _preferences;
    await prefs.remove(_storageKey);
    state = const UserProfileState();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    final profile = entities.UserProfile(
      name: name.trim(),
      email: email.trim(),
    );

    final prefs = await _preferences;
    await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
    state = UserProfileState(profile: profile);
  }
}
