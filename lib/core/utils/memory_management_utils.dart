import 'dart:async';
import 'package:flutter/foundation.dart';

/// Utility for managing memory and cleaning up resources
class MemoryManagementUtils {
  static final Map<String, Timer> _timers = {};
  static final Map<String, StreamSubscription> _subscriptions = {};
  static final Set<String> _activeResources = {};

  /// Register a timer for cleanup
  static void registerTimer(String key, Timer timer) {
    cancelTimer(key);
    _timers[key] = timer;
    _activeResources.add(key);
  }

  /// Cancel a specific timer
  static void cancelTimer(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
    _activeResources.remove(key);
  }

  /// Register a stream subscription for cleanup
  static void registerSubscription(String key, StreamSubscription subscription) {
    cancelSubscription(key);
    _subscriptions[key] = subscription;
    _activeResources.add(key);
  }

  /// Cancel a specific subscription
  static Future<void> cancelSubscription(String key) async {
    await _subscriptions[key]?.cancel();
    _subscriptions.remove(key);
    _activeResources.remove(key);
  }

  /// Cancel all timers
  static void cancelAllTimers() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// Cancel all subscriptions
  static Future<void> cancelAllSubscriptions() async {
    await Future.wait(_subscriptions.values.map((s) => s.cancel()));
    _subscriptions.clear();
  }

  /// Cleanup all resources
  static Future<void> cleanupAll() async {
    cancelAllTimers();
    await cancelAllSubscriptions();
    _activeResources.clear();
  }

  /// Get active resources count
  static int getActiveResourcesCount() {
    return _activeResources.length;
  }

  /// Get resource statistics
  static Map<String, dynamic> getStats() {
    return {
      'activeTimers': _timers.length,
      'activeSubscriptions': _subscriptions.length,
      'totalActiveResources': _activeResources.length,
      'resources': _activeResources.toList(),
    };
  }
}

/// Mixin for automatic resource cleanup
mixin ResourceCleanupMixin {
  final List<Timer> _timers = [];
  final List<StreamSubscription> _subscriptions = [];

  /// Add timer for automatic cleanup
  void addTimer(Timer timer) {
    _timers.add(timer);
  }

  /// Add subscription for automatic cleanup
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Cleanup all resources
  Future<void> cleanupResources() async {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    await Future.wait(_subscriptions.map((s) => s.cancel()));
    _subscriptions.clear();
  }

  /// Get active resources count
  int getActiveResourcesCount() {
    return _timers.length + _subscriptions.length;
  }
}

/// Memory pressure monitor
class MemoryPressureMonitor {
  static final MemoryPressureMonitor _instance = MemoryPressureMonitor._internal();
  factory MemoryPressureMonitor() => _instance;
  MemoryPressureMonitor._internal();

  final List<VoidCallback> _listeners = [];
  Timer? _monitorTimer;
  bool _isMonitoring = false;

  /// Start monitoring memory pressure
  void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitorTimer = Timer.periodic(interval, (_) {
      _checkMemoryPressure();
    });
  }

  /// Stop monitoring
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _isMonitoring = false;
  }

  /// Add memory pressure listener
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Check memory pressure and notify listeners
  void _checkMemoryPressure() {
    // In a real implementation, this would check actual memory usage
    // For now, we'll trigger cleanup periodically
    _notifyListeners();
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        debugPrint('Error in memory pressure listener: $e');
      }
    }
  }

  /// Manual cleanup trigger
  void triggerCleanup() {
    _notifyListeners();
  }
}

/// Disposable resource interface
abstract class DisposableResource {
  bool _isDisposed = false;
  
  bool get isDisposed => _isDisposed;

  /// Dispose the resource
  Future<void> dispose() async {
    if (_isDisposed) return;
    
    await onDispose();
    _isDisposed = true;
  }

  /// Override this method to implement cleanup logic
  Future<void> onDispose();
}

/// Resource pool for reusing expensive objects
class ResourcePool<T> {
  final T Function() _factory;
  final void Function(T)? _reset;
  final List<T> _available = [];
  final Set<T> _inUse = {};
  final int maxSize;

  ResourcePool({
    required T Function() factory,
    void Function(T)? reset,
    this.maxSize = 10,
  })  : _factory = factory,
        _reset = reset;

  /// Acquire a resource from the pool
  T acquire() {
    if (_available.isNotEmpty) {
      final resource = _available.removeLast();
      _inUse.add(resource);
      return resource;
    }

    final resource = _factory();
    _inUse.add(resource);
    return resource;
  }

  /// Release a resource back to the pool
  void release(T resource) {
    if (!_inUse.contains(resource)) return;

    _inUse.remove(resource);
    
    if (_available.length < maxSize) {
      _reset?.call(resource);
      _available.add(resource);
    }
  }

  /// Get pool statistics
  Map<String, int> getStats() {
    return {
      'available': _available.length,
      'inUse': _inUse.length,
      'total': _available.length + _inUse.length,
    };
  }

  /// Clear the pool
  void clear() {
    _available.clear();
    _inUse.clear();
  }
}

/// Batch processor for reducing memory overhead
class BatchProcessor<T> {
  final Future<void> Function(List<T>) _processor;
  final int batchSize;
  final Duration flushInterval;
  
  final List<T> _buffer = [];
  Timer? _flushTimer;

  BatchProcessor({
    required Future<void> Function(List<T>) processor,
    this.batchSize = 50,
    this.flushInterval = const Duration(seconds: 5),
  }) : _processor = processor {
    _startFlushTimer();
  }

  /// Add item to batch
  Future<void> add(T item) async {
    _buffer.add(item);
    
    if (_buffer.length >= batchSize) {
      await flush();
    }
  }

  /// Add multiple items
  Future<void> addAll(List<T> items) async {
    _buffer.addAll(items);
    
    if (_buffer.length >= batchSize) {
      await flush();
    }
  }

  /// Flush the buffer
  Future<void> flush() async {
    if (_buffer.isEmpty) return;

    final batch = List<T>.from(_buffer);
    _buffer.clear();
    
    try {
      await _processor(batch);
    } catch (e) {
      debugPrint('Error processing batch: $e');
    }
  }

  /// Start auto-flush timer
  void _startFlushTimer() {
    _flushTimer = Timer.periodic(flushInterval, (_) => flush());
  }

  /// Stop and cleanup
  Future<void> dispose() async {
    _flushTimer?.cancel();
    await flush();
  }

  /// Get buffer size
  int getBufferSize() {
    return _buffer.length;
  }
}

/// Debouncer for reducing excessive operations
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// Run action with debouncing
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose
  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler for rate limiting operations
class Throttler {
  final Duration interval;
  DateTime? _lastExecution;
  Timer? _pendingTimer;

  Throttler({required this.interval});

  /// Run action with throttling
  void run(VoidCallback action) {
    final now = DateTime.now();
    
    if (_lastExecution == null || 
        now.difference(_lastExecution!) >= interval) {
      _lastExecution = now;
      action();
      return;
    }

    // Schedule for next available slot
    _pendingTimer?.cancel();
    final nextSlot = _lastExecution!.add(interval);
    final delay = nextSlot.difference(now);
    
    _pendingTimer = Timer(delay, () {
      _lastExecution = DateTime.now();
      action();
    });
  }

  /// Cancel pending action
  void cancel() {
    _pendingTimer?.cancel();
  }

  /// Dispose
  void dispose() {
    _pendingTimer?.cancel();
  }
}