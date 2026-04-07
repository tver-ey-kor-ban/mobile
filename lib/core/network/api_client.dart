import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Generic API response wrapper
class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? errorMessage;
  final int statusCode;

  ApiResponse({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    required this.statusCode,
  });

  factory ApiResponse.success(dynamic data, {int statusCode = 200}) {
    return ApiResponse(
      isSuccess: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 500}) {
    return ApiResponse(
      isSuccess: false,
      errorMessage: message,
      statusCode: statusCode,
    );
  }
}

/// HTTP Client for making API requests
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _authToken;
  final http.Client _httpClient = http.Client();

  /// Set the authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear the authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Get headers for API requests
  Map<String, String> _getHeaders({bool requiresAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// Make a GET request
  Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ));
      }

      final response = await _httpClient.get(
        uri,
        headers: _getHeaders(requiresAuth: requiresAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Make a POST request
  Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _httpClient.post(
        uri,
        headers: _getHeaders(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Make a POST request with form data (x-www-form-urlencoded)
  Future<ApiResponse> postForm(
    String endpoint, {
    Map<String, String>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = _getHeaders(requiresAuth: requiresAuth);
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
      
      final response = await _httpClient.post(
        uri,
        headers: headers,
        body: body,
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Make a PUT request
  Future<ApiResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _httpClient.put(
        uri,
        headers: _getHeaders(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Make a DELETE request
  Future<ApiResponse> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _httpClient.delete(
        uri,
        headers: _getHeaders(requiresAuth: requiresAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        final data = jsonDecode(body);
        return ApiResponse.success(data, statusCode: statusCode);
      } catch (e) {
        return ApiResponse.success(body, statusCode: statusCode);
      }
    } else {
      String errorMessage = 'Request failed';
      try {
        final errorData = jsonDecode(body);
        errorMessage = errorData['detail'] ??
            errorData['message'] ??
            errorData['error'] ??
            'Request failed with status $statusCode';
      } catch (e) {
        errorMessage = 'Request failed with status $statusCode';
      }
      return ApiResponse.error(errorMessage, statusCode: statusCode);
    }
  }
}
