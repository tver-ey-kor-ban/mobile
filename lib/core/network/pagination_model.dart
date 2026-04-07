/// Generic pagination model for API responses
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    this.totalPages = 0,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    final itemsList = json['items'] ?? json['data'] ?? json['results'] ?? [];
    final total = json['total'] ?? json['total_count'] ?? json['count'] ?? 0;
    final page = json['page'] ?? json['current_page'] ?? 1;
    final limit = json['limit'] ?? json['per_page'] ?? 10;
    final totalPages = (total / limit).ceil();

    return PaginatedResponse(
      items: (itemsList as List).map((item) => fromJson(item)).toList(),
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      hasNext: page < totalPages,
      hasPrevious: page > 1,
    );
  }

  /// Create empty pagination response
  factory PaginatedResponse.empty() {
    return PaginatedResponse(
      items: [],
      total: 0,
      page: 1,
      limit: 10,
      totalPages: 0,
      hasNext: false,
      hasPrevious: false,
    );
  }
}

/// Pagination request parameters
class PaginationParams {
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  PaginationParams({
    this.page = 1,
    this.limit = 10,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (sortBy != null) params['sort_by'] = sortBy;
    if (sortOrder != null) params['sort_order'] = sortOrder;
    return params;
  }

  PaginationParams copyWith({
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Filter parameters for shop listings
class ShopFilterParams {
  final String? city;
  final String? search;
  final double? minRating;
  final double? maxRating;
  final bool? isOpen;
  final List<String>? services;

  ShopFilterParams({
    this.city,
    this.search,
    this.minRating,
    this.maxRating,
    this.isOpen,
    this.services,
  });

  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{};
    if (city != null && city!.isNotEmpty) params['city'] = city;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (minRating != null) params['min_rating'] = minRating;
    if (maxRating != null) params['max_rating'] = maxRating;
    if (isOpen != null) params['is_open'] = isOpen;
    if (services != null && services!.isNotEmpty) {
      params['services'] = services!.join(',');
    }
    return params;
  }

  ShopFilterParams copyWith({
    String? city,
    String? search,
    double? minRating,
    double? maxRating,
    bool? isOpen,
    List<String>? services,
  }) {
    return ShopFilterParams(
      city: city ?? this.city,
      search: search ?? this.search,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      isOpen: isOpen ?? this.isOpen,
      services: services ?? this.services,
    );
  }
}
