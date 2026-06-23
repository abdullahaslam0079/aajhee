import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:goluto/src/features/settings/domain/entities/user_profile.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class UserProfileState {
  const UserProfileState({
    this.profile = UserProfile.defaultProfile,
    this.isLoading = false,
  });

  final UserProfile profile;
  final bool isLoading;

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>(
  (ref) => UserProfileNotifier(),
);

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier() : super(const UserProfileState(isLoading: true)) {
    _load();
  }

  static const _storageKey = 'user_profile';

  SharedPreferences? _prefs;

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
      state = UserProfileState(profile: UserProfile.fromJson(decoded));
    } catch (_) {
      state = const UserProfileState();
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final profile = UserProfile(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
    );

    final prefs = await _preferences;
    await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
    state = UserProfileState(profile: profile);
  }
}
