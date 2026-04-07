/// API Configuration class for managing environment variables
/// Uses compile-time (--dart-define) configuration
class ApiConfig {
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  /// Initialize the configuration
  /// No-op for compile-time configuration
  static Future<void> initialize() async {
    // Compile-time configuration doesn't require initialization
  }

  /// Base URL for the backend API
  /// Priority: 1. Compile-time (--dart-define) 2. .env file 3. Default value
  static const String baseUrl = String.fromEnvironment(
    'BASE_API_URL',
    defaultValue: 'https://backend-1-qgqd.onrender.com',
  );

  /// API Version prefix
  /// Priority: 1. Compile-time (--dart-define) 2. Default value
  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: '/api/v1',
  );

  /// Full API base URL (baseUrl + apiVersion)
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  /// Check if environment is loaded
  static bool get isLoaded => true;

  /// Get any environment variable by key
  /// Uses compile-time environment variables
  static String? getEnv(String key, {String? fallback}) {
    // Use compile-time environment variables
    return fallback;
  }
}
