
/// Deployment configuration for different environments
class DeploymentConfig {
  final String environment;
  final String apiBaseUrl;
  final String firebaseProjectId;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool enableDebugLogs;
  final int apiTimeout;
  final Map<String, dynamic> features;

  const DeploymentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.firebaseProjectId,
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.enableDebugLogs,
    required this.apiTimeout,
    required this.features,
  });

  /// Development configuration
  static const development = DeploymentConfig(
    environment: 'development',
    apiBaseUrl: 'http://localhost:3000/api',
    firebaseProjectId: 'pm-ajay-dev',
    enableAnalytics: false,
    enableCrashReporting: false,
    enableDebugLogs: true,
    apiTimeout: 30,
    features: {
      'ai_features': true,
      'blockchain': true,
      'geofencing': true,
      'offline_mode': true,
    },
  );

  /// Staging configuration
  static const staging = DeploymentConfig(
    environment: 'staging',
    apiBaseUrl: 'https://staging-api.pm-ajay.gov.in/api',
    firebaseProjectId: 'pm-ajay-staging',
    enableAnalytics: true,
    enableCrashReporting: true,
    enableDebugLogs: true,
    apiTimeout: 30,
    features: {
      'ai_features': true,
      'blockchain': true,
      'geofencing': true,
      'offline_mode': true,
    },
  );

  /// Production configuration
  static const production = DeploymentConfig(
    environment: 'production',
    apiBaseUrl: 'https://api.pm-ajay.gov.in/api',
    firebaseProjectId: 'pm-ajay-prod',
    enableAnalytics: true,
    enableCrashReporting: true,
    enableDebugLogs: false,
    apiTimeout: 30,
    features: {
      'ai_features': true,
      'blockchain': true,
      'geofencing': true,
      'offline_mode': true,
    },
  );

  /// Get current configuration based on build mode
  static DeploymentConfig get current {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    
    switch (environment) {
      case 'staging':
        return staging;
      case 'production':
        return production;
      default:
        return development;
    }
  }

  /// Check if feature is enabled
  bool isFeatureEnabled(String featureName) {
    return features[featureName] == true;
  }

  /// Check if running in production
  bool get isProduction => environment == 'production';

  /// Check if running in development
  bool get isDevelopment => environment == 'development';

  /// Check if running in staging
  bool get isStaging => environment == 'staging';

  @override
  String toString() {
    return 'DeploymentConfig(environment: $environment, apiBaseUrl: $apiBaseUrl)';
  }
}

/// Environment variables manager
class EnvironmentVariables {
  static const String apiKey = String.fromEnvironment('API_KEY', defaultValue: '');
  static const String encryptionKey = String.fromEnvironment('ENCRYPTION_KEY', defaultValue: '');
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  static const String googleMapsKey = String.fromEnvironment('GOOGLE_MAPS_KEY', defaultValue: '');
  
  /// Validate required environment variables
  static void validate() {
    if (DeploymentConfig.current.isProduction) {
      assert(apiKey.isNotEmpty, 'API_KEY is required in production');
      assert(encryptionKey.isNotEmpty, 'ENCRYPTION_KEY is required in production');
    }
  }
}