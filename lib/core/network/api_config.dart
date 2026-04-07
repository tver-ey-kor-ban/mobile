import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration class for managing environment variables
/// Supports both compile-time (--dart-define) and runtime (.env) configuration
class ApiConfig {
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  /// Initialize the configuration by loading the .env file
  /// Call this in main.dart before running the app
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  /// Base URL for the backend API
  /// Priority: 1. Compile-time (--dart-define) 2. .env file 3. Default value
  static const String baseUrl = String.fromEnvironment(
    'BASE_API_URL',
    defaultValue: 'https://backend-1-qgqd.onrender.com',
  );

  /// API Version prefix
  /// Priority: 1. Compile-time (--dart-define) 2. .env file 3. Default value
  static String get apiVersion {
    const version = String.fromEnvironment('API_VERSION');
    if (version.isNotEmpty) return version;
    return dotenv.env['API_VERSION'] ?? '/api/v1';
  }

  /// Full API base URL (baseUrl + apiVersion)
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  /// Check if environment is loaded
  static bool get isLoaded => dotenv.isInitialized;

  /// Get any environment variable by key
  /// Checks compile-time first, then .env file
  static String? getEnv(String key, {String? fallback}) {
    // Try compile-time first
    const compileValue = String.fromEnvironment('');
    if (compileValue.isNotEmpty) return compileValue;
    // Fall back to .env
    return dotenv.env[key] ?? fallback;
  }
}
