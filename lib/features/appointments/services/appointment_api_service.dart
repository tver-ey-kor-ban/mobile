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
      final appts =
          (list as List).map((e) => AppointmentModel.fromJson(e)).toList();
      return await Future.wait(appts.map((appt) => _resolveNames(appt)));
    }
    return [];
  }

  Future<AppointmentModel?> getAppointmentById(int id) async {
    final response = await _apiClient.get(ApiConstants.myAppointmentById(id));
    if (response.isSuccess) {
      final appt = AppointmentModel.fromJson(response.data);
      return await _resolveNames(appt);
    }
    return null;
  }

  Future<AppointmentModel> _resolveNames(AppointmentModel appt) async {
    String? shopName = appt.shopName;
    String? serviceName = appt.serviceName;

    if (appt.shopId != null &&
        (shopName == null || shopName.isEmpty || shopName == 'N/A')) {
      try {
        final shopRes =
            await _apiClient.get(ApiConstants.browseShopInfo(appt.shopId!));
        if (shopRes.isSuccess && shopRes.data != null) {
          shopName = shopRes.data['name'];
        }
      } catch (_) {}
    }

    if (appt.shopId != null &&
        appt.serviceId != null &&
        (serviceName == null || serviceName.isEmpty || serviceName == 'N/A')) {
      try {
        final serviceRes = await _apiClient
            .get(ApiConstants.browseService(appt.shopId!, appt.serviceId!));
        if (serviceRes.isSuccess && serviceRes.data != null) {
          serviceName = serviceRes.data['name'];
        }
      } catch (_) {}
    }

    if (shopName != appt.shopName || serviceName != appt.serviceName) {
      return AppointmentModel(
        id: appt.id,
        serviceId: appt.serviceId,
        serviceName: serviceName ?? appt.serviceName,
        shopName: shopName ?? appt.shopName,
        shopId: appt.shopId,
        appointmentDate: appt.appointmentDate,
        status: appt.status,
        vehicleInfo: appt.vehicleInfo,
        notes: appt.notes,
        totalAmount: appt.totalAmount,
        createdAt: appt.createdAt,
      );
    }
    return appt;
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
