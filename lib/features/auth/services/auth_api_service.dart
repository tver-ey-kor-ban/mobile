import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../data/models/auth_models.dart';

/// Service class for handling authentication API calls
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Set the authentication token for API requests
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Clear the authentication token
  void clearAuthToken() {
    _apiClient.clearAuthToken();
  }

  /// Login with username and password
  /// POST /api/v1/auth/login
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.postForm(
      ApiConstants.login,
      body: request.toFormData(),
    );

    if (response.isSuccess) {
      return LoginResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Login failed',
        statusCode: response.statusCode,
      );
    }
  }

  /// Register a new user
  /// POST /api/v1/auth/register
  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      body: request.toJson(),
    );

    if (response.isSuccess) {
      return RegisterResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Registration failed',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get current authenticated user
  /// GET /api/v1/auth/me
  Future<UserResponse> getCurrentUser() async {
    final response = await _apiClient.get(ApiConstants.currentUser);

    if (response.isSuccess) {
      return UserResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to get user',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get current user's roles from JWT token
  /// GET /api/v1/auth/me/roles
  Future<UserRolesResponse> getUserRoles() async {
    final response = await _apiClient.get(ApiConstants.userRoles);

    if (response.isSuccess) {
      return UserRolesResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to get user roles',
        statusCode: response.statusCode,
      );
    }
  }

  void _handleError(ApiResponse response) {
    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException(
            message: response.errorMessage ?? 'Unauthorized');
      case 403:
        throw UnauthorizedException(
            message: response.errorMessage ?? 'Forbidden');
      case 404:
        throw NotFoundException(
            message: response.errorMessage ?? 'Not found');
      case 422:
        throw ValidationException(
          response.errorMessage ?? 'Validation failed',
          errors: response.data?['errors'],
        );
      default:
        throw ServerException(
          response.errorMessage ?? 'Server error',
          statusCode: response.statusCode,
        );
    }
  }
}
