class ShopProduct {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? currency;
  final String? category;
  final String? brand;
  final bool isAvailable;
  final int? stockQuantity;
  final double? rating;
  final int? ratingCount;
  final String? imageUrl;

  ShopProduct({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.currency,
    this.category,
    this.brand,
    required this.isAvailable,
    this.stockQuantity,
    this.rating,
    this.ratingCount,
    this.imageUrl,
  });

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    return ShopProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'],
      category: json['category'],
      brand: json['brand'],
      isAvailable: json['is_available'] ?? true,
      stockQuantity: json['stock_quantity'],
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      ratingCount: json['rating_count'],
      imageUrl: json['image_url'] as String?,
    );
  }
}

class ShopServiceItem {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? currency;
  final int? estimatedMinutes;
  final bool isAvailable;
  final double? rating;
  final int? ratingCount;
  final String? imageUrl;

  ShopServiceItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.currency,
    this.estimatedMinutes,
    required this.isAvailable,
    this.rating,
    this.ratingCount,
    this.imageUrl,
  });

  factory ShopServiceItem.fromJson(Map<String, dynamic> json) {
    return ShopServiceItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'],
      estimatedMinutes: json['estimated_duration_minutes'] ??
          json['estimated_minutes'] ??
          json['duration_minutes'],
      isAvailable: json['is_available'] ?? true,
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      ratingCount: json['rating_count'],
      imageUrl: json['image_url'] as String?,
    );
  }
}

List<T> _parseItems<T>(dynamic raw, T Function(Map<String, dynamic>) fn) {
  if (raw == null) return [];
  if (raw is List) {
    return raw.map((e) => fn(e as Map<String, dynamic>)).toList();
  }
  return [];
}

class BrowseProductsResponse {
  final List<ShopProduct> products;
  final int total;

  BrowseProductsResponse({required this.products, required this.total});

  factory BrowseProductsResponse.fromJson(dynamic json) {
    if (json is List) {
      final list = _parseItems(json, ShopProduct.fromJson);
      return BrowseProductsResponse(products: list, total: list.length);
    }
    final m = json as Map<String, dynamic>;
    final raw = m['products'] ?? m['items'] ?? m['data'] ?? [];
    final list = _parseItems(raw, ShopProduct.fromJson);
    return BrowseProductsResponse(
      products: list,
      total: (m['total'] ?? m['total_count'] ?? list.length) as int,
    );
  }
}

class BrowseServicesResponse {
  final List<ShopServiceItem> services;
  final int total;

  BrowseServicesResponse({required this.services, required this.total});

  factory BrowseServicesResponse.fromJson(dynamic json) {
    if (json is List) {
      final list = _parseItems(json, ShopServiceItem.fromJson);
      return BrowseServicesResponse(services: list, total: list.length);
    }
    final m = json as Map<String, dynamic>;
    final raw = m['services'] ?? m['items'] ?? m['data'] ?? [];
    final list = _parseItems(raw, ShopServiceItem.fromJson);
    return BrowseServicesResponse(
      services: list,
      total: (m['total'] ?? m['total_count'] ?? list.length) as int,
    );
  }
}
