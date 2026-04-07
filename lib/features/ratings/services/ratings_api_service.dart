import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../data/models/rating_model.dart';

/// Service class for handling ratings-related API calls
class RatingsApiService {
  final ApiClient _apiClient;

  RatingsApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Set the authentication token for API requests
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Clear the authentication token
  void clearAuthToken() {
    _apiClient.clearAuthToken();
  }

  /// Rate a product
  /// POST /api/v1/ratings/products/{productId}
  Future<RatingResponse> rateProduct(int productId, RatingRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.rateProduct(productId),
      body: request.toJson(),
    );

    if (response.isSuccess) {
      return RatingResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to rate product',
        statusCode: response.statusCode,
      );
    }
  }

  /// Rate a service
  /// POST /api/v1/ratings/services/{serviceId}
  Future<RatingResponse> rateService(int serviceId, RatingRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.rateService(serviceId),
      body: request.toJson(),
    );

    if (response.isSuccess) {
      return RatingResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to rate service',
        statusCode: response.statusCode,
      );
    }
  }

  /// Rate a mechanic
  /// POST /api/v1/ratings/mechanics/{mechanicId}
  Future<RatingResponse> rateMechanic(int mechanicId, RatingRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.rateMechanic(mechanicId),
      body: request.toJson(),
    );

    if (response.isSuccess) {
      return RatingResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to rate mechanic',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get ratings for a product with pagination
  /// GET /api/v1/ratings/products/{productId}?page={page}&limit={limit}
  Future<RatingsListResponse> getProductRatings(
    int productId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.getProductRatings(productId),
      queryParams: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.isSuccess) {
      return RatingsListResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to fetch product ratings',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get ratings for a service with pagination
  /// GET /api/v1/ratings/services/{serviceId}?page={page}&limit={limit}
  Future<RatingsListResponse> getServiceRatings(
    int serviceId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.getServiceRatings(serviceId),
      queryParams: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.isSuccess) {
      return RatingsListResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to fetch service ratings',
        statusCode: response.statusCode,
      );
    }
  }

  void _handleError(ApiResponse response) {
    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException(
            message: response.errorMessage ?? 'Unauthorized');
      case 404:
        throw NotFoundException(
            message: response.errorMessage ?? 'Resource not found');
      case 422:
        throw ValidationException(
          response.errorMessage ?? 'Validation failed',
          errors: response.data?['errors'],
        );
      case 409:
        throw ValidationException(
          response.errorMessage ?? 'Already rated',
        );
      default:
        throw ServerException(
          response.errorMessage ?? 'Server error',
          statusCode: response.statusCode,
        );
    }
  }
}
