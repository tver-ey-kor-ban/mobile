import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../data/models/shop_model.dart';

/// Service class for handling shop-related API calls
class ShopApiService {
  final ApiClient _apiClient;

  ShopApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Set the authentication token for API requests
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Clear the authentication token
  void clearAuthToken() {
    _apiClient.clearAuthToken();
  }

  /// Create a new shop (Shop Owner only)
  /// POST /api/v1/shops
  Future<ShopResponse> createShop(CreateShopRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.shops,
      body: request.toJson(),
    );

    if (response.isSuccess) {
      return ShopResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to create shop',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get list of shops with pagination
  /// GET /api/v1/shops?page={page}&limit={limit}
  Future<ShopsListResponse> getShops({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (filters != null) {
      queryParams.addAll(filters);
    }

    final response = await _apiClient.get(
      ApiConstants.shops,
      queryParams: queryParams,
    );

    if (response.isSuccess) {
      return ShopsListResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to fetch shops',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get shop details by ID
  /// GET /api/v1/shops/{id}
  Future<ShopResponse> getShopById(int shopId) async {
    final response = await _apiClient.get(
      '${ApiConstants.shopDetails}$shopId',
    );

    if (response.isSuccess) {
      return ShopResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to fetch shop details',
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
            message: response.errorMessage ?? 'Forbidden - Shop Owner access only');
      case 404:
        throw NotFoundException(
            message: response.errorMessage ?? 'Shop not found');
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
