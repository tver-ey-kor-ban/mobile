import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../data/models/rating_model.dart';

class RatingsApiService {
  final ApiClient _apiClient;

  RatingsApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void setAuthToken(String token) => _apiClient.setAuthToken(token);
  void clearAuthToken() => _apiClient.clearAuthToken();

  /// POST /ratings/products
  Future<RatingResponse> rateProduct(ProductRatingRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.rateProduct,
      body: request.toJson(),
    );
    if (response.isSuccess) return RatingResponse.fromJson(response.data);
    _handleError(response);
    throw ServerException(
      response.errorMessage ?? 'Failed to rate product',
      statusCode: response.statusCode,
    );
  }

  /// POST /ratings/services
  Future<RatingResponse> rateService(ServiceRatingRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.rateService,
      body: request.toJson(),
    );
    if (response.isSuccess) return RatingResponse.fromJson(response.data);
    _handleError(response);
    throw ServerException(
      response.errorMessage ?? 'Failed to rate service',
      statusCode: response.statusCode,
    );
  }

  /// POST /shops/{shopId}/mechanics/{mechanicId}/rate
  Future<RatingResponse> rateMechanic(
    int shopId,
    int mechanicId,
    MechanicRatingRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.rateMechanic(shopId, mechanicId),
      body: request.toJson(),
    );
    if (response.isSuccess) return RatingResponse.fromJson(response.data);
    _handleError(response);
    throw ServerException(
      response.errorMessage ?? 'Failed to rate mechanic',
      statusCode: response.statusCode,
    );
  }

  /// GET /ratings/products/{productId}/reviews
  Future<RatingsListResponse> getProductRatings(
    int productId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.getProductRatings(productId),
      queryParams: {'page': page, 'limit': limit},
    );
    if (response.isSuccess) return RatingsListResponse.fromJson(response.data);
    _handleError(response);
    throw ServerException(
      response.errorMessage ?? 'Failed to fetch product ratings',
      statusCode: response.statusCode,
    );
  }

  /// GET /ratings/services/{serviceId}/reviews
  Future<RatingsListResponse> getServiceRatings(
    int serviceId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.getServiceRatings(serviceId),
      queryParams: {'page': page, 'limit': limit},
    );
    if (response.isSuccess) return RatingsListResponse.fromJson(response.data);
    _handleError(response);
    throw ServerException(
      response.errorMessage ?? 'Failed to fetch service ratings',
      statusCode: response.statusCode,
    );
  }

  /// GET /ratings/products/{productId}/summary
  Future<RatingSummary> getProductRatingSummary(int productId) async {
    final response = await _apiClient.get(
      ApiConstants.productRatingSummary(productId),
    );
    if (response.isSuccess) return RatingSummary.fromJson(response.data);
    _handleError(response);
    throw ServerException(
      response.errorMessage ?? 'Failed to fetch product rating summary',
      statusCode: response.statusCode,
    );
  }

  /// GET /ratings/services/{serviceId}/summary
  Future<RatingSummary> getServiceRatingSummary(int serviceId) async {
    final response = await _apiClient.get(
      ApiConstants.serviceRatingSummary(serviceId),
    );
    if (response.isSuccess) return RatingSummary.fromJson(response.data);
    _handleError(response);
    throw ServerException(
      response.errorMessage ?? 'Failed to fetch service rating summary',
      statusCode: response.statusCode,
    );
  }

  /// GET /ratings/my-ratings
  Future<RatingsListResponse> getMyRatings() async {
    final response = await _apiClient.get(ApiConstants.myRatings);
    if (response.isSuccess) return RatingsListResponse.fromJson(response.data);
    _handleError(response);
    throw ServerException(
      response.errorMessage ?? 'Failed to fetch my ratings',
      statusCode: response.statusCode,
    );
  }

  void _handleError(dynamic response) {
    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException(
            message: response.errorMessage ?? 'Unauthorized');
      case 404:
        throw NotFoundException(
            message: response.errorMessage ?? 'Resource not found');
      case 409:
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
