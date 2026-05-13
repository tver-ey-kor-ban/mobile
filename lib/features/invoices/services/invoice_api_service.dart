import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../data/models/invoice_model.dart';

class InvoiceApiService {
  final ApiClient _apiClient;

  InvoiceApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void setAuthToken(String token) => _apiClient.setAuthToken(token);

  // Customer endpoints
  Future<List<InvoiceModel>> getMyInvoices() async {
    final response = await _apiClient.get(ApiConstants.myInvoices);
    if (response.isSuccess) {
      final data = response.data;
      final list = data is List ? data : (data['invoices'] ?? []);
      return (list as List).map((e) => InvoiceModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<InvoiceModel?> getMyInvoiceById(int id) async {
    final response = await _apiClient.get(ApiConstants.myInvoiceById(id));
    if (response.isSuccess) return InvoiceModel.fromJson(response.data);
    return null;
  }

  // Shop/Mechanic endpoints
  Future<List<InvoiceModel>> getShopInvoices(int shopId,
      {String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;

    final response = await _apiClient.get(
      ApiConstants.shopInvoices(shopId),
      queryParams: params.isEmpty ? null : params,
    );
    if (response.isSuccess) {
      final data = response.data;
      final list = data is List ? data : (data['invoices'] ?? []);
      return (list as List).map((e) => InvoiceModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> createInvoice(int shopId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.shopInvoices(shopId),
      body: data,
    );
    return response.isSuccess;
  }

  Future<bool> sendInvoice(int shopId, int invoiceId) async {
    final response =
        await _apiClient.post(ApiConstants.sendInvoice(shopId, invoiceId));
    return response.isSuccess;
  }

  Future<bool> recordPayment(
      int shopId, int invoiceId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.recordPayment(shopId, invoiceId),
      body: data,
    );
    return response.isSuccess;
  }
}
