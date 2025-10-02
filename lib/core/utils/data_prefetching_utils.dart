import 'dart:async';
import 'package:flutter/foundation.dart';

/// Utility for prefetching and caching data
class DataPrefetchingUtils {
  static final Map<String, dynamic> _prefetchCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static final Map<String, Future<dynamic>> _pendingFetches = {};
  
  static const Duration defaultCacheDuration = Duration(minutes: 5);

  /// Prefetch data with a key
  static Future<T> prefetch<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    final duration = cacheDuration ?? defaultCacheDuration;

    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid(key, duration)) {
      return _prefetchCache[key] as T;
    }

    // Return pending fetch if exists
    if (_pendingFetches.containsKey(key)) {
      return await _pendingFetches[key] as T;
    }

    // Start new fetch
    final future = fetcher();
    _pendingFetches[key] = future;

    try {
      final data = await future;
      _prefetchCache[key] = data;
      _cacheTimestamps[key] = DateTime.now();
      return data;
    } finally {
      _pendingFetches.remove(key);
    }
  }

  /// Get cached data without fetching
  static T? getCached<T>(String key, {Duration? maxAge}) {
    if (!_prefetchCache.containsKey(key)) return null;
    
    final age = maxAge ?? defaultCacheDuration;
    if (!_isCacheValid(key, age)) {
      _prefetchCache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _prefetchCache[key] as T?;
  }

  /// Check if cache is valid
  static bool _isCacheValid(String key, Duration maxAge) {
    if (!_cacheTimestamps.containsKey(key)) return false;
    
    final timestamp = _cacheTimestamps[key]!;
    final age = DateTime.now().difference(timestamp);
    return age < maxAge;
  }

  /// Invalidate specific cache entry
  static void invalidate(String key) {
    _prefetchCache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// Invalidate all cache entries
  static void invalidateAll() {
    _prefetchCache.clear();
    _cacheTimestamps.clear();
  }

  /// Prefetch multiple items in parallel
  static Future<Map<String, dynamic>> prefetchBatch(
    Map<String, Future<dynamic> Function()> fetchers, {
    Duration? cacheDuration,
  }) async {
    final futures = fetchers.entries.map((entry) async {
      final data = await prefetch(
        key: entry.key,
        fetcher: entry.value,
        cacheDuration: cacheDuration,
      );
      return MapEntry(entry.key, data);
    });

    final results = await Future.wait(futures);
    return Map.fromEntries(results);
  }

  /// Prefetch in background without blocking
  static void prefetchBackground({
    required String key,
    required Future<dynamic> Function() fetcher,
    Duration? cacheDuration,
  }) {
    prefetch(
      key: key,
      fetcher: fetcher,
      cacheDuration: cacheDuration,
    ).catchError((error) {
      debugPrint('Background prefetch failed for $key: $error');
    });
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cachedItems': _prefetchCache.length,
      'pendingFetches': _pendingFetches.length,
      'keys': _prefetchCache.keys.toList(),
    };
  }
}

/// Mixin for data prefetching capabilities
mixin DataPrefetchMixin {
  /// Prefetch data for a key
  Future<T> prefetchData<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) {
    return DataPrefetchingUtils.prefetch(
      key: key,
      fetcher: fetcher,
      cacheDuration: cacheDuration,
      forceRefresh: forceRefresh,
    );
  }

  /// Get cached data
  T? getCachedData<T>(String key, {Duration? maxAge}) {
    return DataPrefetchingUtils.getCached<T>(key, maxAge: maxAge);
  }

  /// Invalidate cache
  void invalidateCache(String key) {
    DataPrefetchingUtils.invalidate(key);
  }

  /// Prefetch multiple items
  Future<Map<String, dynamic>> prefetchBatch(
    Map<String, Future<dynamic> Function()> fetchers, {
    Duration? cacheDuration,
  }) {
    return DataPrefetchingUtils.prefetchBatch(
      fetchers,
      cacheDuration: cacheDuration,
    );
  }
}

/// Strategy for prefetching related data
abstract class PrefetchStrategy {
  Future<void> prefetch();
  List<String> getCacheKeys();
}

/// Prefetch strategy for project-related data
class ProjectPrefetchStrategy implements PrefetchStrategy {
  final String projectId;
  final Future<dynamic> Function(String) projectFetcher;
  final Future<dynamic> Function(String) timelineFetcher;
  final Future<dynamic> Function(String) documentsFetcher;

  ProjectPrefetchStrategy({
    required this.projectId,
    required this.projectFetcher,
    required this.timelineFetcher,
    required this.documentsFetcher,
  });

  @override
  Future<void> prefetch() async {
    await DataPrefetchingUtils.prefetchBatch({
      'project_$projectId': () => projectFetcher(projectId),
      'timeline_$projectId': () => timelineFetcher(projectId),
      'documents_$projectId': () => documentsFetcher(projectId),
    });
  }

  @override
  List<String> getCacheKeys() {
    return [
      'project_$projectId',
      'timeline_$projectId',
      'documents_$projectId',
    ];
  }
}

/// Prefetch strategy for dashboard data
class DashboardPrefetchStrategy implements PrefetchStrategy {
  final Future<dynamic> Function() statsFetcher;
  final Future<dynamic> Function() recentProjectsFetcher;
  final Future<dynamic> Function() notificationsFetcher;

  DashboardPrefetchStrategy({
    required this.statsFetcher,
    required this.recentProjectsFetcher,
    required this.notificationsFetcher,
  });

  @override
  Future<void> prefetch() async {
    await DataPrefetchingUtils.prefetchBatch({
      'dashboard_stats': statsFetcher,
      'dashboard_recent_projects': recentProjectsFetcher,
      'dashboard_notifications': notificationsFetcher,
    });
  }

  @override
  List<String> getCacheKeys() {
    return [
      'dashboard_stats',
      'dashboard_recent_projects',
      'dashboard_notifications',
    ];
  }
}

/// Manager for coordinating prefetch strategies
class PrefetchManager {
  static final PrefetchManager _instance = PrefetchManager._internal();
  factory PrefetchManager() => _instance;
  PrefetchManager._internal();

  final Map<String, PrefetchStrategy> _strategies = {};
  final Set<String> _activePrefetches = {};

  /// Register a prefetch strategy
  void registerStrategy(String name, PrefetchStrategy strategy) {
    _strategies[name] = strategy;
  }

  /// Execute a strategy
  Future<void> executeStrategy(String name) async {
    if (_activePrefetches.contains(name)) {
      debugPrint('Strategy $name is already running');
      return;
    }

    final strategy = _strategies[name];
    if (strategy == null) {
      debugPrint('Strategy $name not found');
      return;
    }

    _activePrefetches.add(name);
    try {
      await strategy.prefetch();
    } finally {
      _activePrefetches.remove(name);
    }
  }

  /// Execute multiple strategies in parallel
  Future<void> executeStrategies(List<String> names) async {
    await Future.wait(names.map((name) => executeStrategy(name)));
  }

  /// Invalidate strategy cache
  void invalidateStrategy(String name) {
    final strategy = _strategies[name];
    if (strategy == null) return;

    for (final key in strategy.getCacheKeys()) {
      DataPrefetchingUtils.invalidate(key);
    }
  }

  /// Get active prefetches
  Set<String> getActivePrefetches() {
    return Set.from(_activePrefetches);
  }

  /// Clear all strategies
  void clearStrategies() {
    _strategies.clear();
    _activePrefetches.clear();
  }
}

/// Prefetch coordinator for managing app-wide prefetching
class PrefetchCoordinator {
  static final PrefetchCoordinator _instance = PrefetchCoordinator._internal();
  factory PrefetchCoordinator() => _instance;
  PrefetchCoordinator._internal();

  final List<String> _prefetchQueue = [];
  bool _isProcessing = false;

  /// Add to prefetch queue
  void queuePrefetch(String strategyName) {
    if (!_prefetchQueue.contains(strategyName)) {
      _prefetchQueue.add(strategyName);
      _processPrefetchQueue();
    }
  }

  /// Process prefetch queue
  Future<void> _processPrefetchQueue() async {
    if (_isProcessing || _prefetchQueue.isEmpty) return;

    _isProcessing = true;
    final manager = PrefetchManager();

    while (_prefetchQueue.isNotEmpty) {
      final strategyName = _prefetchQueue.removeAt(0);
      try {
        await manager.executeStrategy(strategyName);
      } catch (e) {
        debugPrint('Failed to execute prefetch strategy $strategyName: $e');
      }
    }

    _isProcessing = false;
  }

  /// Clear queue
  void clearQueue() {
    _prefetchQueue.clear();
  }

  /// Get queue length
  int getQueueLength() {
    return _prefetchQueue.length;
  }

  /// Check if processing
  bool isProcessing() {
    return _isProcessing;
  }
}