import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../data/models/repair_progress_model.dart';

class RepairProgressApiService {
  final ApiClient _apiClient;

  RepairProgressApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void setAuthToken(String token) => _apiClient.setAuthToken(token);

  // Customer endpoints
  Future<List<RepairProgressModel>> getMyRepairs() async {
    final response = await _apiClient.get(ApiConstants.myRepairs);
    if (response.isSuccess) {
      final data = response.data;
      final list = data is List ? data : (data['repairs'] ?? []);
      return (list as List)
          .map((e) => RepairProgressModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<RepairProgressModel?> getMyRepairById(int id) async {
    final response = await _apiClient.get(ApiConstants.myRepairById(id));
    if (response.isSuccess) return RepairProgressModel.fromJson(response.data);
    return null;
  }

  // Shop/Mechanic endpoints
  Future<List<RepairProgressModel>> getShopRepairs(
    int shopId, {
    String? stage,
  }) async {
    final params = <String, dynamic>{};
    if (stage != null) params['stage'] = stage;

    final response = await _apiClient.get(
      ApiConstants.shopRepairs(shopId),
      queryParams: params.isEmpty ? null : params,
    );
    if (response.isSuccess) {
      final data = response.data;
      final list = data is List ? data : (data['repairs'] ?? []);
      return (list as List)
          .map((e) => RepairProgressModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<RepairProgressModel?> createRepair(
      int shopId, Map<String, dynamic> data) async {
    final response =
        await _apiClient.post(ApiConstants.createRepair(shopId), body: data);
    if (response.isSuccess) return RepairProgressModel.fromJson(response.data);
    return null;
  }

  Future<RepairProgressModel?> updateRepairStage(
      int shopId, int progressId, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
        ApiConstants.updateRepair(shopId, progressId),
        body: data);
    if (response.isSuccess) return RepairProgressModel.fromJson(response.data);
    return null;
  }
}
