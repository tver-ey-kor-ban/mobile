import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class ApiClient {
  final http.Client _client;
  String? _authToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<ApiResponse> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      var url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null) {
        url = url.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
      }
      final response = await _client.get(url, headers: _headers);
      return _handleResponse(response);
    } on SocketException catch (e) {
      return ApiResponse.error('No internet connection: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client.post(
        url,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException catch (e) {
      return ApiResponse.error('No internet connection: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse> postForm(String endpoint,
      {Map<String, String>? body}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      final response = await _client.post(
        url,
        headers: headers,
        body: body,
      );
      return _handleResponse(response);
    } on SocketException catch (e) {
      return ApiResponse.error('No internet connection: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client.put(
        url,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException catch (e) {
      return ApiResponse.error('No internet connection: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client.delete(url, headers: _headers);
      return _handleResponse(response);
    } on SocketException catch (e) {
      return ApiResponse.error('No internet connection: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.success(
        data: body,
        statusCode: response.statusCode,
      );
    } else {
      return ApiResponse.error(
        body['message'] ?? 'Request failed',
        statusCode: response.statusCode,
        data: body,
      );
    }
  }
}

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? errorMessage;
  final int statusCode;

  ApiResponse._({
    required this.success,
    this.data,
    this.errorMessage,
    required this.statusCode,
  });

  factory ApiResponse.success({
    required dynamic data,
    required int statusCode,
  }) {
    return ApiResponse._(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(
    String message, {
    int statusCode = 0,
    dynamic data,
  }) {
    return ApiResponse._(
      success: false,
      errorMessage: message,
      statusCode: statusCode,
      data: data,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}
