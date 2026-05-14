import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../data/models/browse_models.dart';

class BrowseApiService {
  final ApiClient _apiClient;

  BrowseApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  void setAuthToken(String token) => _apiClient.setAuthToken(token);
  void clearAuthToken() => _apiClient.clearAuthToken();

  Future<BrowseProductsResponse> getShopProducts(int shopId, {int page = 1, int limit = 50}) async {
    final response = await _apiClient.get(
      ApiConstants.browseProducts(shopId),
      queryParams: {'page': page, 'limit': limit},
    );
    if (response.isSuccess) {
      return BrowseProductsResponse.fromJson(response.data);
    }
    _handleError(response);
    throw ServerException(
      response.errorMessage ?? 'Failed to load products',
      statusCode: response.statusCode,
    );
  }

  Future<BrowseServicesResponse> getShopServices(int shopId, {int page = 1, int limit = 50}) async {
    final response = await _apiClient.get(
      ApiConstants.browseServices(shopId),
      queryParams: {'page': page, 'limit': limit},
    );
    if (response.isSuccess) {
      return BrowseServicesResponse.fromJson(response.data);
    }
    _handleError(response);
    throw ServerException(
      response.errorMessage ?? 'Failed to load services',
      statusCode: response.statusCode,
    );
  }

  void _handleError(ApiResponse response) {
    if (response.statusCode == 401) {
      throw UnauthorizedException(message: response.errorMessage ?? 'Unauthorized');
    }
    if (response.statusCode == 404) {
      throw NotFoundException(message: response.errorMessage ?? 'Not found');
    }
  }
}
