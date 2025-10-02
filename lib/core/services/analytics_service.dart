import 'package:flutter/foundation.dart';

/// Service for tracking analytics and user behavior
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _isInitialized = false;
  final List<Map<String, dynamic>> _eventQueue = [];
  final Map<String, dynamic> _userProperties = {};

  /// Initialize analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // In production, initialize actual analytics SDK (Firebase Analytics, etc.)
      _isInitialized = true;
      debugPrint('Analytics service initialized');
    } catch (e) {
      debugPrint('Failed to initialize analytics: $e');
    }
  }

  /// Track screen view
  void trackScreenView(String screenName) {
    if (!_isInitialized) return;

    _trackEvent('screen_view', {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track user action
  void trackAction(String action, {Map<String, dynamic>? properties}) {
    if (!_isInitialized) return;

    _trackEvent(action, {
      ...?properties,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track error
  void trackError(String error, {StackTrace? stackTrace}) {
    if (!_isInitialized) return;

    _trackEvent('error', {
      'error_message': error,
      'stack_trace': stackTrace?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track custom event
  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (!_isInitialized) return;

    _trackEvent(eventName, {
      ...?parameters,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Set user properties
  void setUserProperties(Map<String, dynamic> properties) {
    if (!_isInitialized) return;

    _userProperties.addAll(properties);
    debugPrint('User properties updated: $properties');
  }

  /// Set user ID
  void setUserId(String userId) {
    if (!_isInitialized) return;

    _userProperties['user_id'] = userId;
    debugPrint('User ID set: $userId');
  }

  /// Track timing
  void trackTiming(String category, int milliseconds, {String? label}) {
    if (!_isInitialized) return;

    _trackEvent('timing', {
      'category': category,
      'milliseconds': milliseconds,
      'label': label,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Internal event tracking
  void _trackEvent(String name, Map<String, dynamic> parameters) {
    final event = {
      'event_name': name,
      'parameters': parameters,
      'user_properties': Map<String, dynamic>.from(_userProperties),
    };

    _eventQueue.add(event);
    debugPrint('Analytics event: $name');

    // In production, send to analytics backend
    _flushEvents();
  }

  /// Flush event queue
  Future<void> _flushEvents() async {
    if (_eventQueue.isEmpty) return;

    try {
      // In production, batch send events to backend
      debugPrint('Flushing ${_eventQueue.length} analytics events');
      _eventQueue.clear();
    } catch (e) {
      debugPrint('Failed to flush events: $e');
    }
  }

  /// Get event queue for debugging
  List<Map<String, dynamic>> getEventQueue() {
    return List.unmodifiable(_eventQueue);
  }

  /// Clear all data
  void clear() {
    _eventQueue.clear();
    _userProperties.clear();
  }
}

/// Mixin for analytics tracking
mixin AnalyticsMixin {
  final AnalyticsService _analytics = AnalyticsService();

  /// Track screen view
  void trackScreen(String screenName) {
    _analytics.trackScreenView(screenName);
  }

  /// Track action
  void trackAction(String action, {Map<String, dynamic>? properties}) {
    _analytics.trackAction(action, properties: properties);
  }

  /// Track error
  void trackError(String error, {StackTrace? stackTrace}) {
    _analytics.trackError(error, stackTrace: stackTrace);
  }

  /// Track custom event
  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    _analytics.trackEvent(eventName, parameters: parameters);
  }
}

/// Performance timing tracker
class PerformanceTimer {
  final String category;
  final String? label;
  final DateTime _startTime;

  PerformanceTimer(this.category, {this.label}) : _startTime = DateTime.now();

  /// Stop timer and track
  void stop() {
    final duration = DateTime.now().difference(_startTime).inMilliseconds;
    AnalyticsService().trackTiming(category, duration, label: label);
  }
}