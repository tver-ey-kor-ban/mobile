import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../data/models/booking_request_model.dart';

/// Service class for handling booking-related API calls
class BookingApiService {
  final ApiClient _apiClient;

  BookingApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Set the authentication token for API requests
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Clear the authentication token
  void clearAuthToken() {
    _apiClient.clearAuthToken();
  }

  /// Create a unified booking (service + products)
  /// POST /api/v1/product-orders/unified-booking
  Future<BookingResponse> createUnifiedBooking(
      UnifiedBookingRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.unifiedBooking,
      body: request.toJson(),
    );

    if (response.isSuccess) {
      return BookingResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to create booking',
        statusCode: response.statusCode,
      );
    }
  }

  /// Create a product order only
  /// POST /api/v1/product-orders
  Future<BookingResponse> createProductOrder(
      ProductOrderRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.productOrders,
      body: request.toJson(),
    );

    if (response.isSuccess) {
      return BookingResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to create product order',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get all product orders for the current user
  /// GET /api/v1/product-orders
  Future<List<dynamic>> getProductOrders() async {
    final response = await _apiClient.get(ApiConstants.productOrders);

    if (response.isSuccess) {
      return response.data is List ? response.data : [];
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to fetch orders',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get a specific product order by ID
  /// GET /api/v1/product-orders/{id}
  Future<Map<String, dynamic>> getProductOrder(int id) async {
    final response = await _apiClient.get('${ApiConstants.productOrders}/$id');

    if (response.isSuccess) {
      return response.data is Map<String, dynamic> ? response.data : {};
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to fetch order',
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
      default:
        throw ServerException(
          response.errorMessage ?? 'Server error',
          statusCode: response.statusCode,
        );
    }
  }
}
