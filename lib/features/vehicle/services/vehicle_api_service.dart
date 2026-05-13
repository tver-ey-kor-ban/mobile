import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../data/models/vehicle_model.dart';

/// Service class for handling vehicle-related API calls
class VehicleApiService {
  final ApiClient _apiClient;

  VehicleApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Set the authentication token for API requests
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Get all vehicles for the current customer
  /// GET /api/v1/my-vehicles
  Future<VehiclesListResponse> getMyVehicles() async {
    final response = await _apiClient.get(ApiConstants.myVehicles);

    if (response.isSuccess) {
      return VehiclesListResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to fetch vehicles',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get primary vehicle for the current customer
  /// GET /api/v1/my-vehicles/primary
  Future<VehicleResponse?> getPrimaryVehicle() async {
    final response = await _apiClient.get(ApiConstants.primaryVehicle);

    if (response.isSuccess) {
      if (response.data == null || response.data is! Map) {
        return null;
      }
      return VehicleResponse.fromJson(response.data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to fetch primary vehicle',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get specific vehicle details
  /// GET /api/v1/my-vehicles/{id}
  Future<VehicleResponse> getVehicle(int id) async {
    final response = await _apiClient.get(ApiConstants.myVehicleDetail(id));

    if (response.isSuccess) {
      return VehicleResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to fetch vehicle',
        statusCode: response.statusCode,
      );
    }
  }

  /// Add a new vehicle
  /// POST /api/v1/my-vehicles
  Future<VehicleResponse> addVehicle(CreateVehicleRequest request) async {
    final response = await _apiClient.post(
      ApiConstants.myVehicles,
      body: request.toJson(),
    );

    if (response.isSuccess) {
      return VehicleResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to add vehicle',
        statusCode: response.statusCode,
      );
    }
  }

  /// Update a vehicle
  /// PUT /api/v1/my-vehicles/{id}
  Future<VehicleResponse> updateVehicle(
    int id,
    CreateVehicleRequest request,
  ) async {
    final response = await _apiClient.put(
      ApiConstants.myVehicleDetail(id),
      body: request.toJson(),
    );

    if (response.isSuccess) {
      return VehicleResponse.fromJson(response.data);
    } else {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to update vehicle',
        statusCode: response.statusCode,
      );
    }
  }

  /// Set a vehicle as primary
  /// POST /api/v1/my-vehicles/{id}/set-primary
  Future<void> setPrimaryVehicle(int id) async {
    final response = await _apiClient.post(
      ApiConstants.setPrimaryVehicle(id),
    );

    if (!response.isSuccess) {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to set primary vehicle',
        statusCode: response.statusCode,
      );
    }
  }

  /// Delete a vehicle
  /// DELETE /api/v1/my-vehicles/{id}
  Future<void> deleteVehicle(int id) async {
    final response = await _apiClient.delete(
      ApiConstants.myVehicleDetail(id),
    );

    if (!response.isSuccess) {
      _handleError(response);
      throw ServerException(
        response.errorMessage ?? 'Failed to delete vehicle',
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
            message: response.errorMessage ?? 'Vehicle not found');
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
