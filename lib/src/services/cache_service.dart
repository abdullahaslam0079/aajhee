import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../utils/utils.dart';
import 'storage_service.dart';

/// Clears app caches (prefs user data + image memory/disk) on logout.
class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  /// Wipes user-related SharedPreferences and all image caches.
  FutureEither<void> clearAll() async {
    return runTask(() async {
      await StorageService.instance.clearUserData();
      await _clearImageCaches();
      AppLogger.info('App caches cleared');
    });
  }

  Future<void> _clearImageCaches() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await DefaultCacheManager().emptyCache();
  }
}
