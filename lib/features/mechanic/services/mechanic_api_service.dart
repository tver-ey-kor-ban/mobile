import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../data/models/mechanic_booking_model.dart';

class MechanicApiService {
  final ApiClient _apiClient;

  MechanicApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void setAuthToken(String token) => _apiClient.setAuthToken(token);

  // My Shops
  Future<List<MyShopModel>> getMyShops() async {
    final response = await _apiClient.get(ApiConstants.myShops);
    if (response.isSuccess) {
      final data = response.data;
      final list = data is List ? data : <dynamic>[];
      return list.map((e) => MyShopModel.fromJson(e)).toList();
    }
    return [];
  }

  // Pending Bookings — API returns { total, page, limit, items: [...] }
  Future<Map<String, dynamic>> getPendingBookings(int shopId) async {
    final response = await _apiClient.get(ApiConstants.pendingBookings(shopId));
    if (response.isSuccess) {
      final data = response.data;
      // "items" is the paginated envelope key; fall back to legacy keys
      final raw = data['items'] ?? data['bookings'] ?? data['data'] ?? [];
      final bookingsList = (raw as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((e) => MechanicBookingModel.fromJson(e))
          .toList();
      return {
        'count': data['total'] ?? data['count'] ?? bookingsList.length,
        'bookings': bookingsList,
      };
    }
    return {'count': 0, 'bookings': <MechanicBookingModel>[]};
  }

  // Booking detail
  Future<MechanicBookingModel?> getBookingDetail(int shopId, int apptId) async {
    final response = await _apiClient
        .get(ApiConstants.mechanicBookingDetail(shopId, apptId));
    if (response.isSuccess) {
      return MechanicBookingModel.fromJson(response.data);
    }
    return null;
  }

  // Accept booking
  Future<bool> acceptBooking(int shopId, int apptId, {String? notes}) async {
    final response = await _apiClient.post(
      ApiConstants.mechanicBookingAction(shopId, apptId),
      body: {'action': 'accept', if (notes != null) 'notes': notes},
    );
    return response.isSuccess;
  }

  // Reject booking
  Future<bool> rejectBooking(int shopId, int apptId, String reason) async {
    final response = await _apiClient.post(
      ApiConstants.mechanicBookingAction(shopId, apptId),
      body: {'action': 'reject', 'reason': reason},
    );
    return response.isSuccess;
  }

  // Today's bookings
  Future<List<MechanicBookingModel>> getTodayBookings(int shopId) async {
    final response = await _apiClient.get(ApiConstants.todayBookings(shopId));
    if (response.isSuccess) {
      final data = response.data;
      final list = data is List ? data : (data['bookings'] ?? []);
      return (list as List)
          .map((e) => MechanicBookingModel.fromJson(e))
          .toList();
    }
    return [];
  }

  // Pending Orders — API returns { total, page, limit, items: [...] }
  Future<List<MechanicOrderModel>> getPendingOrders(int shopId) async {
    final response = await _apiClient.get(ApiConstants.pendingOrders(shopId));
    if (response.isSuccess) {
      final data = response.data;
      // "items" is the paginated envelope key; fall back to legacy keys
      final raw = data is List
          ? data
          : (data['items'] ?? data['orders'] ?? data['data'] ?? []);
      return (raw as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => MechanicOrderModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<bool> acceptOrder(int shopId, int orderId) async {
    final response = await _apiClient.post(
      ApiConstants.mechanicOrderAction(shopId, orderId),
      body: {'action': 'accept'},
    );
    return response.isSuccess;
  }

  Future<bool> rejectOrder(int shopId, int orderId, String reason) async {
    final response = await _apiClient.post(
      ApiConstants.mechanicOrderAction(shopId, orderId),
      body: {'action': 'reject', 'reason': reason},
    );
    return response.isSuccess;
  }

  Future<bool> markOrderReady(int shopId, int orderId) async {
    final response =
        await _apiClient.put(ApiConstants.markOrderReady(shopId, orderId));
    return response.isSuccess;
  }

  // My Performance
  Future<Map<String, dynamic>?> getMyPerformance(int shopId) async {
    final response = await _apiClient.get(ApiConstants.myPerformance(shopId));
    if (response.isSuccess) return Map<String, dynamic>.from(response.data);
    return null;
  }

  // All mechanics performance (owner)
  Future<Map<String, dynamic>?> getAllMechanicsPerformance(int shopId) async {
    final response =
        await _apiClient.get(ApiConstants.shopMechanicsPerformance(shopId));
    if (response.isSuccess) return Map<String, dynamic>.from(response.data);
    return null;
  }

  // Shop statistics (owner/mechanic)
  Future<Map<String, dynamic>?> getShopStatistics(int shopId) async {
    final response = await _apiClient.get(ApiConstants.shopStatistics(shopId));
    if (response.isSuccess) return Map<String, dynamic>.from(response.data);
    return null;
  }

  // Lightweight pending counts for dashboard badges
  Future<int> getPendingBookingCount(int shopId) async {
    final response = await _apiClient.get(
      ApiConstants.pendingBookings(shopId),
      queryParams: {'page': 1, 'limit': 1},
    );
    if (response.isSuccess) {
      final data = response.data;
      return (data['total'] ?? data['count'] ?? 0) as int;
    }
    return 0;
  }

  Future<int> getPendingOrderCount(int shopId) async {
    final response = await _apiClient.get(
      ApiConstants.pendingOrders(shopId),
      queryParams: {'page': 1, 'limit': 1},
    );
    if (response.isSuccess) {
      final data = response.data;
      return (data['total'] ?? data['count'] ?? 0) as int;
    }
    return 0;
  }

  Future<int> getTodayBookingCount(int shopId) async {
    final response = await _apiClient.get(ApiConstants.todayBookings(shopId));
    if (response.isSuccess) {
      final data = response.data;
      return (data['count'] ?? 0) as int;
    }
    return 0;
  }
}
