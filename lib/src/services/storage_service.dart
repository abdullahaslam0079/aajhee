import 'package:shared_preferences/shared_preferences.dart';
import '../utils/utils.dart';

/// A wrapper around [SharedPreferences] for simple key-value persistence.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;
  Future<SharedPreferences>? _prefsFuture;

  bool get isInitialized => _prefs != null;

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) return _prefs!;
    _prefsFuture ??= SharedPreferences.getInstance();
    _prefs = await _prefsFuture!;
    return _prefs!;
  }

  /// Initialize SharedPreferences instance.
  FutureEither<void> init() async {
    return runTask(() async {
      await _ensurePrefs();
      AppLogger.info('StorageService (SharedPreferences) initialized');
    });
  }

  // --- SETTERS ---

  FutureEither<bool> setString(String key, String value) async =>
      runTask(() async {
        final prefs = await _ensurePrefs();
        return prefs.setString(key, value);
      });

  FutureEither<bool> setBool(String key, bool value) async =>
      runTask(() async {
        final prefs = await _ensurePrefs();
        return prefs.setBool(key, value);
      });

  FutureEither<bool> setInt(String key, int value) async =>
      runTask(() async {
        final prefs = await _ensurePrefs();
        return prefs.setInt(key, value);
      });

  FutureEither<bool> setDouble(String key, double value) async =>
      runTask(() async {
        final prefs = await _ensurePrefs();
        return prefs.setDouble(key, value);
      });

  FutureEither<bool> setStringList(String key, List<String> value) async =>
      runTask(() async {
        final prefs = await _ensurePrefs();
        return prefs.setStringList(key, value);
      });

  // --- GETTERS ---

  String? getString(String key) {
    final prefs = _prefs;
    if (prefs == null) return null;
    return prefs.getString(key);
  }

  bool? getBool(String key) {
    final prefs = _prefs;
    if (prefs == null) return null;
    return prefs.getBool(key);
  }

  int? getInt(String key) {
    final prefs = _prefs;
    if (prefs == null) return null;
    return prefs.getInt(key);
  }

  double? getDouble(String key) {
    final prefs = _prefs;
    if (prefs == null) return null;
    return prefs.getDouble(key);
  }

  List<String>? getStringList(String key) {
    final prefs = _prefs;
    if (prefs == null) return null;
    return prefs.getStringList(key);
  }

  // --- COMMON ---

  bool containsKey(String key) {
    final prefs = _prefs;
    if (prefs == null) return false;
    return prefs.containsKey(key);
  }

  FutureEither<bool> remove(String key) async =>
      runTask(() async {
        final prefs = await _ensurePrefs();
        return prefs.remove(key);
      });

  FutureEither<bool> clear() async =>
      runTask(() async {
        final prefs = await _ensurePrefs();
        return prefs.clear();
      });

  /// Clears persisted user data while keeping device-level keys (e.g. onboarding).
  FutureEither<bool> clearUserData({
    Set<String> preserveKeys = const {'onboarding_completed'},
  }) async =>
      runTask(() async {
        final prefs = await _ensurePrefs();
        final keys = prefs.getKeys().difference(preserveKeys);
        for (final key in keys) {
          await prefs.remove(key);
        }
        return true;
      });
}
