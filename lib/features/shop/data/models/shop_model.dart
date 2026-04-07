/// Model for creating a shop
/// POST /api/v1/shops
class CreateShopRequest {
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final bool isActive;

  CreateShopRequest({
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'is_active': isActive,
    };
    if (description != null) data['description'] = description;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    return data;
  }
}

/// Model for shop response
class ShopResponse {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final bool isActive;
  final int? ownerId;
  final String? createdAt;
  final double? rating;
  final int? ratingCount;

  ShopResponse({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    required this.isActive,
    this.ownerId,
    this.createdAt,
    this.rating,
    this.ratingCount,
  });

  factory ShopResponse.fromJson(Map<String, dynamic> json) {
    return ShopResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      isActive: json['is_active'] ?? true,
      ownerId: json['owner_id'],
      createdAt: json['created_at'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      ratingCount: json['rating_count'],
    );
  }
}

/// Model for shop list response with pagination
class ShopsListResponse {
  final List<ShopResponse> shops;
  final int total;
  final int page;
  final int limit;

  ShopsListResponse({
    required this.shops,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory ShopsListResponse.fromJson(Map<String, dynamic> json) {
    final shopsList = json['shops'] ?? json['data'] ?? json['items'] ?? [];
    return ShopsListResponse(
      shops: (shopsList as List)
          .map((item) => ShopResponse.fromJson(item))
          .toList(),
      total: json['total'] ?? json['total_count'] ?? 0,
      page: json['page'] ?? json['current_page'] ?? 1,
      limit: json['limit'] ?? json['per_page'] ?? 10,
    );
  }
}
