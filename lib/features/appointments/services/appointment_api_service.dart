import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../data/models/appointment_model.dart';

class AppointmentApiService {
  final ApiClient _apiClient;

  AppointmentApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void setAuthToken(String token) => _apiClient.setAuthToken(token);

  Future<List<AppointmentModel>> getMyAppointments({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;

    final response = await _apiClient.get(
      ApiConstants.myAppointments,
      queryParams: params.isEmpty ? null : params,
    );

    if (response.isSuccess) {
      final data = response.data;
      final list =
          data is List ? data : (data['appointments'] ?? data['items'] ?? []);
      return (list as List).map((e) => AppointmentModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<AppointmentModel?> getAppointmentById(int id) async {
    final response = await _apiClient.get(ApiConstants.myAppointmentById(id));
    if (response.isSuccess) {
      return AppointmentModel.fromJson(response.data);
    }
    return null;
  }

  Future<bool> cancelAppointment(int id) async {
    final response = await _apiClient.put(ApiConstants.cancelAppointment(id));
    return response.isSuccess;
  }

  Future<List<dynamic>> getServiceHistory() async {
    final response = await _apiClient.get(ApiConstants.myServiceHistory);
    if (response.isSuccess) {
      return response.data is List ? response.data : [];
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMyOrders({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['order_status'] = status;

    final response = await _apiClient.get(
      ApiConstants.myOrders,
      queryParams: params.isEmpty ? null : params,
    );

    if (response.isSuccess) {
      final data = response.data;
      final list =
          data is List ? data : (data['orders'] ?? data['items'] ?? []);
      return (list as List).map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  Future<bool> cancelOrder(int id) async {
    final response = await _apiClient.put(ApiConstants.cancelMyOrder(id));
    return response.isSuccess;
  }
}
