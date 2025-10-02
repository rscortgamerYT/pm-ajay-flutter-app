import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for crash reporting and error monitoring
class CrashReportingService {
  static final CrashReportingService _instance = CrashReportingService._internal();
  factory CrashReportingService() => _instance;
  CrashReportingService._internal();

  bool _isInitialized = false;
  final List<CrashReport> _crashReports = [];
  final Map<String, dynamic> _customData = {};

  /// Initialize crash reporting
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // In production, initialize crash reporting SDK (Firebase Crashlytics, Sentry, etc.)
      FlutterError.onError = _handleFlutterError;
      _isInitialized = true;
      debugPrint('Crash reporting service initialized');
    } catch (e) {
      debugPrint('Failed to initialize crash reporting: $e');
    }
  }

  /// Record error
  void recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    if (!_isInitialized) return;

    final report = CrashReport(
      exception: exception.toString(),
      stackTrace: stackTrace?.toString(),
      reason: reason,
      fatal: fatal,
      timestamp: DateTime.now(),
      customData: Map<String, dynamic>.from(_customData),
    );

    _crashReports.add(report);
    debugPrint('Error recorded: ${exception.toString()}');

    // In production, send to crash reporting backend
    _sendReport(report);
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    recordError(
      details.exception,
      details.stack,
      reason: details.context?.toString(),
      fatal: false,
    );
  }

  /// Set custom key-value data
  void setCustomKey(String key, dynamic value) {
    _customData[key] = value;
  }

  /// Set user identifier
  void setUserIdentifier(String userId) {
    _customData['user_id'] = userId;
  }

  /// Log message
  void log(String message) {
    if (!_isInitialized) return;
    debugPrint('Crash log: $message');
  }

  /// Send crash report
  Future<void> _sendReport(CrashReport report) async {
    try {
      // In production, send to backend
      debugPrint('Sending crash report: ${report.exception}');
    } catch (e) {
      debugPrint('Failed to send crash report: $e');
    }
  }

  /// Get crash reports (for debugging)
  List<CrashReport> getCrashReports() {
    return List.unmodifiable(_crashReports);
  }

  /// Clear crash reports
  void clearReports() {
    _crashReports.clear();
  }

  /// Check if initialized
  bool get isInitialized => _isInitialized;
}

/// Represents a crash report
class CrashReport {
  final String exception;
  final String? stackTrace;
  final String? reason;
  final bool fatal;
  final DateTime timestamp;
  final Map<String, dynamic> customData;

  CrashReport({
    required this.exception,
    this.stackTrace,
    this.reason,
    required this.fatal,
    required this.timestamp,
    required this.customData,
  });

  Map<String, dynamic> toJson() {
    return {
      'exception': exception,
      'stackTrace': stackTrace,
      'reason': reason,
      'fatal': fatal,
      'timestamp': timestamp.toIso8601String(),
      'customData': customData,
    };
  }
}

/// Zone guard for catching uncaught errors
class ErrorZoneGuard {
  /// Run app with error handling
  static Future<void> runGuarded(Future<void> Function() app) async {
    await runZonedGuarded(
      () async {
        await app();
      },
      (error, stackTrace) {
        CrashReportingService().recordError(
          error,
          stackTrace,
          fatal: true,
        );
      },
    );
  }
}