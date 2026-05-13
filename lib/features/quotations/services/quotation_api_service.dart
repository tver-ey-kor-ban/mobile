import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../data/models/quotation_model.dart';

class QuotationApiService {
  final ApiClient _apiClient;

  QuotationApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void setAuthToken(String token) => _apiClient.setAuthToken(token);

  // Customer endpoints
  Future<List<QuotationModel>> getMyQuotations() async {
    final response = await _apiClient.get(ApiConstants.myQuotations);
    if (response.isSuccess) {
      final data = response.data;
      final list = data is List ? data : (data['quotations'] ?? []);
      return (list as List).map((e) => QuotationModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<QuotationModel?> getMyQuotationById(int id) async {
    final response = await _apiClient.get(ApiConstants.myQuotationById(id));
    if (response.isSuccess) return QuotationModel.fromJson(response.data);
    return null;
  }

  Future<bool> approveQuotation(int id) async {
    final response = await _apiClient.post(
      ApiConstants.quotationAction(id),
      body: {'action': 'approve'},
    );
    return response.isSuccess;
  }

  Future<bool> rejectQuotation(int id, String reason) async {
    final response = await _apiClient.post(
      ApiConstants.quotationAction(id),
      body: {'action': 'reject', 'rejection_reason': reason},
    );
    return response.isSuccess;
  }

  // Shop/Mechanic endpoints
  Future<List<QuotationModel>> getShopQuotations(int shopId,
      {String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;

    final response = await _apiClient.get(
      ApiConstants.shopQuotations(shopId),
      queryParams: params.isEmpty ? null : params,
    );
    if (response.isSuccess) {
      final data = response.data;
      final list = data is List ? data : (data['quotations'] ?? []);
      return (list as List).map((e) => QuotationModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createQuotation(int shopId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.shopQuotations(shopId),
      body: data,
    );
    return response.isSuccess;
  }

  Future<bool> sendQuotation(int shopId, int quotationId) async {
    final response = await _apiClient.post(
      ApiConstants.sendQuotation(shopId, quotationId),
    );
    return response.isSuccess;
  }
}
