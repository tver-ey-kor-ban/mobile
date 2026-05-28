import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../data/models/vehicle_model.dart';

class VehicleApiService {
  final ApiClient _apiClient;

  VehicleApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void setAuthToken(String token) => _apiClient.setAuthToken(token);

  Future<List<VehicleModel>> getMyVehicles() async {
    final response = await _apiClient.get(ApiConstants.myVehicles);
    if (response.isSuccess) {
      final data = response.data;
      final list = data is List ? data : <dynamic>[];
      return list.map((e) => VehicleModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<VehicleModel?> getVehicleById(int id) async {
    final response = await _apiClient.get(ApiConstants.myVehicleById(id));
    if (response.isSuccess) return VehicleModel.fromJson(response.data);
    return null;
  }

  Future<VehicleModel?> addVehicle(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.myVehicles, body: data);
    if (response.isSuccess) return VehicleModel.fromJson(response.data);
    return null;
  }

  Future<VehicleModel?> updateVehicle(int id, Map<String, dynamic> data) async {
    final response =
        await _apiClient.put(ApiConstants.myVehicleById(id), body: data);
    if (response.isSuccess) return VehicleModel.fromJson(response.data);
    return null;
  }

  Future<bool> deleteVehicle(int id) async {
    final response = await _apiClient.delete(ApiConstants.myVehicleById(id));
    return response.isSuccess;
  }

  Future<bool> setVehiclePrimary(int id) async {
    final response = await _apiClient.post(ApiConstants.setVehiclePrimary(id));
    return response.isSuccess;
  }

  Future<VehicleModel?> getPrimaryVehicle() async {
    final response = await _apiClient.get(ApiConstants.primaryVehicle);
    if (response.isSuccess) return VehicleModel.fromJson(response.data);
    return null;
  }
}
