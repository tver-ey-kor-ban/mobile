import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../data/models/search_result_model.dart';

class GlobalSearchService {
  final ApiClient _apiClient = ApiClient();

  Future<SearchResponse> search({
    required String query,
    String type = 'all',
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.globalSearch,
      queryParams: {
        'q': query,
        'type': type,
        'page': page,
        'limit': limit,
      },
    );
    if (response.isSuccess) {
      return SearchResponse.fromJson(response.data as Map<String, dynamic>);
    }
    return SearchResponse(items: [], total: 0, page: page, limit: limit);
  }
}
