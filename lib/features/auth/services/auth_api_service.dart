import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../data/models/auth_models.dart';

/// Service class for handling authentication-related API calls
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Login user and get JWT token
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

  /// Register new user
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

  /// Refresh access token
  /// POST /api/v1/auth/refresh
  Future<LoginResponse> refreshToken(RefreshTokenRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.refreshToken,
      body: request.toJson(),
    );

    if (response.isSuccess) {
      return LoginResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Token refresh failed',
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

  void _handleError(ApiResponse response) {
    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException(
            message: response.errorMessage ?? 'Invalid credentials');
      case 404:
        throw NotFoundException(
            message: response.errorMessage ?? 'User not found');
      case 422:
        throw ValidationException(
          response.errorMessage ?? 'Validation failed',
          errors: response.data?['errors'],
        );
      case 409:
        throw ValidationException(
          response.errorMessage ?? 'User already exists',
        );
      default:
        throw ServerException(
          response.errorMessage ?? 'Server error',
          statusCode: response.statusCode,
        );
    }
  }
}
