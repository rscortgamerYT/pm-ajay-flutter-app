import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing application performance optimizations
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  Box? _cacheBox;
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, dynamic> _memoryCache = {};
  
  // Cache configuration
  static const Duration defaultCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 1);
  static const int maxMemoryCacheSize = 100;

  /// Initialize the performance service
  Future<void> initialize() async {
    try {
      _cacheBox = await Hive.openBox('performance_cache');
      _loadCacheTimestamps();
    } catch (e) {
      debugPrint('Failed to initialize performance service: $e');
    }
  }

  /// Load cache timestamps from storage
  void _loadCacheTimestamps() {
    if (_cacheBox == null) return;
    
    for (final key in _cacheBox!.keys) {
      final timestamp = _cacheBox!.get('${key}_timestamp');
      if (timestamp != null) {
        _cacheTimestamps[key.toString()] = DateTime.parse(timestamp);
      }
    }
  }

  /// Get cached data with expiration check
  Future<T?> getCached<T>(
    String key, {
    Duration? maxAge,
  }) async {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      if (_isCacheValid(key, maxAge)) {
        return _memoryCache[key] as T?;
      } else {
        _memoryCache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }

    // Check persistent cache
    if (_cacheBox != null) {
      if (_isCacheValid(key, maxAge)) {
        final data = _cacheBox!.get(key);
        if (data != null) {
          // Promote to memory cache
          _addToMemoryCache(key, data);
          return data as T?;
        }
      } else {
        await _cacheBox!.delete(key);
        await _cacheBox!.delete('${key}_timestamp');
        _cacheTimestamps.remove(key);
      }
    }

    return null;
  }

  /// Set cached data with timestamp
  Future<void> setCached<T>(
    String key,
    T data, {
    bool persistToDisk = true,
  }) async {
    final timestamp = DateTime.now();
    _cacheTimestamps[key] = timestamp;
    
    // Add to memory cache
    _addToMemoryCache(key, data);

    // Persist to disk if requested
    if (persistToDisk && _cacheBox != null) {
      await _cacheBox!.put(key, data);
      await _cacheBox!.put('${key}_timestamp', timestamp.toIso8601String());
    }
  }

  /// Add data to memory cache with size limit
  void _addToMemoryCache(String key, dynamic data) {
    if (_memoryCache.length >= maxMemoryCacheSize) {
      // Remove oldest entry
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _memoryCache.remove(oldestKey);
    }
    _memoryCache[key] = data;
  }

  /// Check if cache is still valid
  bool _isCacheValid(String key, Duration? maxAge) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    
    final age = DateTime.now().difference(timestamp);
    final maxCacheAge = maxAge ?? defaultCacheDuration;
    return age < maxCacheAge;
  }

  /// Clear all caches
  Future<void> clearAll() async {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    if (_cacheBox != null) {
      await _cacheBox!.clear();
    }
  }

  /// Clear cache for specific key
  Future<void> clearCache(String key) async {
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
    if (_cacheBox != null) {
      await _cacheBox!.delete(key);
      await _cacheBox!.delete('${key}_timestamp');
    }
  }

  /// Clear expired caches
  Future<void> clearExpired({Duration? maxAge}) async {
    final expiredKeys = <String>[];
    final maxCacheAge = maxAge ?? defaultCacheDuration;

    for (final entry in _cacheTimestamps.entries) {
      final age = DateTime.now().difference(entry.value);
      if (age >= maxCacheAge) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      await clearCache(key);
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'memoryCacheSize': _memoryCache.length,
      'diskCacheSize': _cacheBox?.length ?? 0,
      'totalCachedKeys': _cacheTimestamps.length,
      'oldestEntry': _cacheTimestamps.entries.isEmpty
          ? null
          : _cacheTimestamps.entries
              .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
              .value
              .toIso8601String(),
    };
  }

  /// Preload frequently accessed data
  Future<void> preloadData(Map<String, Future<dynamic> Function()> loaders) async {
    await Future.wait(
      loaders.entries.map((entry) async {
        final cachedData = await getCached(entry.key);
        if (cachedData == null) {
          final data = await entry.value();
          await setCached(entry.key, data);
        }
      }),
    );
  }

  /// Batch get multiple cached items
  Future<Map<String, dynamic>> batchGet(List<String> keys) async {
    final results = <String, dynamic>{};
    
    for (final key in keys) {
      final data = await getCached(key);
      if (data != null) {
        results[key] = data;
      }
    }
    
    return results;
  }

  /// Batch set multiple cached items
  Future<void> batchSet(Map<String, dynamic> items, {bool persistToDisk = true}) async {
    for (final entry in items.entries) {
      await setCached(entry.key, entry.value, persistToDisk: persistToDisk);
    }
  }
}

/// Mixin for adding caching capabilities to providers
mixin CacheMixin {
  final PerformanceService _performanceService = PerformanceService();

  /// Get cached data or compute if not cached
  Future<T> cached<T>(
    String key,
    Future<T> Function() compute, {
    Duration? maxAge,
    bool persistToDisk = true,
  }) async {
    // Try to get from cache
    final cached = await _performanceService.getCached<T>(key, maxAge: maxAge);
    if (cached != null) return cached;

    // Compute and cache
    final data = await compute();
    await _performanceService.setCached(key, data, persistToDisk: persistToDisk);
    return data;
  }

  /// Invalidate cache for key
  Future<void> invalidateCache(String key) async {
    await _performanceService.clearCache(key);
  }

  /// Invalidate multiple cache keys
  Future<void> invalidateCaches(List<String> keys) async {
    for (final key in keys) {
      await invalidateCache(key);
    }
  }
}