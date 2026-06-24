import 'dart:convert';

import 'package:goluto/src/features/settings/domain/entities/user_profile.dart'
    as entities;
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_provider.g.dart';

class UserProfileState {
  const UserProfileState({
    this.profile = entities.UserProfile.defaultProfile,
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
    _load();
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
      if (raw == null || raw.isEmpty) {
        state = const UserProfileState();
        return;
      }

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      state = UserProfileState(profile: entities.UserProfile.fromJson(decoded));
    } catch (_) {
      state = const UserProfileState();
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final profile = entities.UserProfile(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
    );

    final prefs = await _preferences;
    await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
    state = UserProfileState(profile: profile);
  }
}
