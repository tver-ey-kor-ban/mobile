import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../data/models/notification_model.dart';

class NotificationApiService {
  final ApiClient _apiClient;

  NotificationApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void setAuthToken(String token) => _apiClient.setAuthToken(token);

  Future<Map<String, dynamic>> getMyNotifications({
    String? status,
    int limit = 50,
  }) async {
    final params = <String, dynamic>{'limit': limit.toString()};
    if (status != null) params['status'] = status;

    final response = await _apiClient.get(
      ApiConstants.myNotifications,
      queryParams: params,
    );

    if (response.isSuccess) {
      final data = response.data;
      final notifList = (data['notifications'] as List<dynamic>? ?? [])
          .map((e) => NotificationModel.fromJson(e))
          .toList();
      return {
        'unread_count': data['unread_count'] ?? 0,
        'notifications': notifList,
      };
    }
    return {'unread_count': 0, 'notifications': <NotificationModel>[]};
  }

  Future<bool> markAsRead(int id) async {
    final response =
        await _apiClient.put(ApiConstants.markNotificationRead(id));
    return response.isSuccess;
  }
}
