import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

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

  static const String _rawBaseUrl = String.fromEnvironment(
    'BASE_API_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Base URL for the backend API
  /// Priority: 1. Compile-time (--dart-define) 2. .env file 3. Default value
  /// Automatically redirects to 10.0.2.2 for Android Emulators when pointing to localhost
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      if (_rawBaseUrl == 'http://localhost:8000') {
        return 'http://10.0.2.2:8000';
      } else if (_rawBaseUrl == 'http://127.0.0.1:8000') {
        return 'http://10.0.2.2:8000';
      } else if (_rawBaseUrl.contains('localhost')) {
        return _rawBaseUrl.replaceAll('localhost', '10.0.2.2');
      } else if (_rawBaseUrl.contains('127.0.0.1')) {
        return _rawBaseUrl.replaceAll('127.0.0.1', '10.0.2.2');
      }
    }
    return _rawBaseUrl;
  }

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
